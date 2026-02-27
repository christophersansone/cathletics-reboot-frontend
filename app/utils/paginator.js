import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { task } from 'ember-concurrency';
import { assert } from '@ember/debug';

const DISPLAY_TYPES = [ 'infinite' , 'page' ];
const DEFAULT_PAGE_SIZE = 100;

/* This unit is a modern take on paginating both the data and the UX.
   It makes no assumptions about how to fetch the data for each page.
   At the core, it uses promises and is much like a promise: on creation,
   pass in the function that performs the fetch, given a page number.
   The function result should be an array (or more often, a promise resolving to an array)
   of records.  Any pagination strategy other than page numbers
   (e.g. a JSON API response returning a "next" link) is supported
   to the extent that can be done, but it is the responsibility of the fetch function.

   The results of each fetch are cached here so that subsequent requests
   for the same page are returned immediately.

   Both infinite scroll and classic page navigation are supported.
   In infinite mode, the expectation is that it only awaits the first page,
   subsequent pages are loaded as promises, and `displayItems` contains all records.
   In page mode, it awaits each page change, and `displayItems` contains the records
   on the current page.
*/
export default class Paginator {
  fetchFn = null;
  pageSize = null;

  // total can be externally set if / when the parent knows the total --
  // this likely occurs during the fetch --
  // the total is not required or even used by the paginator...
  // it is helpful for display purposes, e.g. the pagination buttons
  @tracked total = null;

  // the current page number -- do not change this directly --
  // instead, use the page navigation functions (nextPage, previousPage, navigateToPage)
  @tracked pageNumber = 0;
  // the array of page promises from the time they were first requested
  @tracked pagePromises = [];
  // the array of pages, where each page is an array of records
  @tracked pages = [];
  // the display type, which is set upon creation and can either be "infinite" or "page"
  @tracked displayType = 'infinite';
  // specifies whether there are more records beyond the current page --
  // it simply checks whether the current page record count equals the page size --
  // if so, it assumes there are more records -- if not, there must be fewer records,
  // and therefore it is the final page and there are no more records
  @tracked hasMore = true;

  // the promise of the first page -- this is set immediately upon creation
  firstPage = null;

  // pass fetch function, and optionally the page size and display type
  constructor(fetchFn, pageSize = DEFAULT_PAGE_SIZE, displayType = 'infinite') {
    this.fetchFn = fetchFn;
    this.pageSize = pageSize || DEFAULT_PAGE_SIZE;
    this.displayType = displayType;
    if (!DISPLAY_TYPES.includes(displayType)) {
      throw new Error(`Invalid displayType: "${displayType}"`);
    }
    this.firstPage = this.nextPage();
  }

  // returns a promise resolving with the (first) set of records to display --
  // when 'page', it returns the current page promise
  // when 'infinite', it returns the first page only -- subsequent pages are loaded later
  get displayPromise() {
    const displayType = this.displayType;
    if (displayType === 'infinite') {
      return this.firstPage;
    } else if (displayType === 'page') {
      return this.currentPage;
    } else {
      throw new Error(`Invalid displayType: "${displayType}"`);
    }
  }

  // returns the actual current items to display, based on the display type --
  // this is how the vertical collection expects to receive page after page
  // when 'page', it returns the current page
  // when 'infinite', it returns all items from all pages
  get displayItems() {
    const displayType = this.displayType;
    if (displayType === 'infinite') {
      return this.allItems;
    } else if (displayType === 'page') {
      return this.pages[this.pageNumber - 1];
    } else {
      throw new Error(`Invalid displayType: "${displayType}"`);
    }
  }

  // returns all items across all pages
  get allItems() {
    return this.pages.filter((p) => !!p).flat();
  }

  get infinite() {
    return this.displayType === 'infinite';
  }

  // returns a promise that resolves to the current page items
  get currentPage() {
    return this.pagePromises[this.pageNumber - 1];
  }

  @action
  reload() {
    this.total = null;
    this.pageNumber = 0;
    this.pagePromises = [];
    this.pages = [];
    this.hasMore = true;
    this.firstPage = this.nextPage();
  }

  @action
  navigateToPage(pageNumber) {
    return this.navigateToPageTask.perform(pageNumber);
  }

  @action
  nextPage() {
    if (this.hasMore) {
      return this.navigateToPage(this.pageNumber + 1);
    }
  }

  @action
  previousPage() {
    return this.navigateToPage(this.pageNumber - 1);
  }

  navigateToPageTask = task({ drop: true }, async (pageNumber) => {
    if (pageNumber > 0) {
      this.pageNumber = pageNumber;
      const result = await this.fetchPageTask.perform(pageNumber);
      this.hasMore = result.length === this.pageSize;
      return result;
    }
  });

  fetchPageTask = task({ enqueue: true }, async (pageNumber) => {
    const index = pageNumber - 1;
    if (!this.pages[index]) {
      const pagePromise = this.fetchFn(pageNumber, this.pageSize);
      this.pagePromises = this.insertInto(this.pagePromises, pagePromise, index);
      let pageResult = await pagePromise;
      // convert array-like Ember objects such as Ember Data RecordArrays
      if (!Array.isArray(pageResult)) {
        if (pageResult.toArray) {
          pageResult = pageResult.toArray();
        } else {
          assert(`The pagination function must return an array`);
        }
      }
      this.pages = this.insertInto(this.pages, pageResult, index);
    }
    return this.pages[index];
  });

  insertInto(array, item, index) {
    let result = [...array];
    // fill any missing items with null in case we are skipping pages
    for (let i = result.length; i < index; i++) {
      result[i] = null;
    }
    result[index] = item;
    return result;
  }
}

