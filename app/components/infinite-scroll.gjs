import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { action } from '@ember/object';
import { modifier } from 'ember-modifier';
import { and, eq } from 'ember-truth-helpers';
import LoadingIndicator from './ui/loading-indicator';
import { TrackedSet } from 'tracked-built-ins';
import Paginator from 'frontend/utils/paginator';
import args from 'frontend/decorators/args';

const DEFAULT_THRESHOLD = '600px';

/*
  The ultimate Infinite Scroll Component, Paginator aware, fully customizable,
  with sensible defaults, loading indicators, and occlusion support out of the box.
  Works with any parent element, including tables, lists, grids, etc.

  <InfiniteScroll @paginator={{this.paginator}} as |item|>
    ...
  </InfiniteScroll>

  To add a custom loading indicator, use the `loading` block.
  You must apply the `loadingModifier` to the top-level loading element
  so that it can observe when it is near the viewport.

  <InfiniteScroll @paginator={{this.paginator}}>
    <:item as |item|>
      ...
    </:item>
    <:loading as |loadingModifier|>
      <div class="loading" {{loadingModifier}}>
        ...
      </div>
    </:loading>
  </InfiniteScroll>

  To add a custom empty state:

  <InfiniteScroll @paginator={{this.paginator}}>
    <:item as |item|>
      ...
    </:item>
    <:empty>
      ...
    </:empty>
  </InfiniteScroll>

  To enable occluding, add `@occlude={{true}}`.  Occlusion works by inserting a "sentinel" element
  at the top of each page.  When the page is visible, the element has zero height.  When the page is occluded,
  the element's height becomes the page height, and the items are then removed from the DOM.  For standard
  elements that can have a div inserted as a child, this is automatically done for you.  For parent elements
  that require specific markup such as tables, you must define the `sentinel` block and apply the `sentinelModifier`
  to the top-level sentinel element so that it can observe when it is near the viewport.

  <table>
    <tbody>
      <InfiniteScroll @paginator={{this.paginator}} @occlude={{true}}>
        <:item as |item|>
          <tr>...</tr>
        </:item>
        <:sentinel as |sentinelModifier|>
          <tr {{sentinelModifier}}>
            ...
          </tr>
        </:sentinel>
      </InfiniteScroll>
    </tbody>
  </table>
*/


@args({
  paginator: { type: Paginator, required: true },
  scrollElement: {},
  threshold: { type: 'string' },
  occlude: { type: 'boolean'},
  onOcclude: { type: 'function'},
})
export default class InfiniteScroll extends Component {
  visiblePages = new TrackedSet();

  // Internal state for spatial tracking
  pageHeights = new Map();
  pageElements = new Map();
  sentinelElement = null;

  @cached
  get pageIntersectionObserver() {
    if (!this.args.occlude) return null;

    return new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => this.pageSentinelIntersected(entry));
      },
      {
        root: this.args.scrollElement ?? null,
        rootMargin: `${this.args.threshold ?? DEFAULT_THRESHOLD} 0px`,
        threshold: 0.01,
      }
    );
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.pageIntersectionObserver?.disconnect();
  }

  pageSentinelIntersected(entry) {
    const pageIndex = parseInt(entry.target.dataset.pageIndex);
    const boundingClientRect = entry.boundingClientRect;
    const rootBounds = entry.rootBounds || { top: 0, bottom: window.innerHeight };
    if (entry.isIntersecting) {
      // ENTRY SCENARIOS
      if (boundingClientRect.top >= rootBounds.top) {
        // Entering from bottom (user scrolling down)
        // Show the page corresponding to this sentinel
        this.showPage(pageIndex);
      } else {
        // Entering from top (user scrolling up)
        // When occluded, the sentinel is the entire page height -- show it
        this.showPage(pageIndex);
      }
    } else {
      // EXIT SCENARIOS
      if (boundingClientRect.top < rootBounds.top) {
        // Exiting from top (user scrolling down)
        this.occludePage(pageIndex - 1);
      } else {
        // Exiting from bottom (user scrolling up)
        this.occludePage(pageIndex);
      }
    }
  }

  showPage(index) {
    if (this.visiblePages.has(index)) return;
    this.visiblePages.add(index);
    const element = this.pageElements.get(index);
    element.style.height = 'auto';
  }

  occludePage(index) {
    if (!this.visiblePages.has(index)) return;
    this.visiblePages.delete(index);
    const height = this.measurePageHeight(index);
    const element = this.pageElements.get(index);
    element.style.height = `${height}px`;
    this.args.onOcclude?.(index, element);
  }

  measurePageHeight(index) {
    if (index < 0 || !this.pageElements.has(index)) return;

    const pageSentinel = this.pageElements.get(index);
    const nextSentinel = this.pageElements.get(index + 1) ?? this.loadingSentinelElement;

    const bottom = nextSentinel ? nextSentinel.getBoundingClientRect().top : pageSentinel.parentElement.getBoundingClientRect().bottom;
    const height = bottom - pageSentinel.getBoundingClientRect().top;
    if (height > 0) {
      this.pageHeights.set(index, height);
    }
    return height;
  }

  @action
  sentinelModifier(index) {
    // generates and returns a modifier bound to the specific page index
    if (!this.args.occlude) return;
    return modifier((element) => {
      element.dataset.pageIndex = index;
      this.pageElements.set(index, element);
      this.pageIntersectionObserver.observe(element);

      return () => {
        this.pageIntersectionObserver.unobserve(element);
      };
    });
  }

  loadingModifier = modifier((element) => {
    this.loadingSentinelElement = element;
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && this.args.paginator.hasMore) {
          this.args.paginator.nextPage();
        }
      },
      {
        root: this.args.scrollElement ?? null,
        rootMargin: `${this.args.threshold ?? DEFAULT_THRESHOLD} 0px`,
        threshold: 0.01,
      }
    );
    observer.observe(element);

    return () => {
      observer.disconnect();
      this.loadingSentinelElement = null;
    };
  })

  @action
  isPageVisible(index) {
    if (!this.args.occlude) return true;
    return this.visiblePages.has(index) || !this.pageHeights.has(index);
  }

  <template>
    <style scoped>
      .loading {
        display: flex;
        justify-content: center;
        padding: var(--space-4) 0;
      }

      :global(.infinite-scroll-page-sentinel) {
        padding: 0 !important;
        margin: 0 !important;
        height: 0;
        border: 0 !important;
        visibility: hidden !important;
      }
    </style>

    {{#each @paginator.pages as |page pageIndex|}}
      {{#if @occlude}}
        {{#if (has-block 'sentinel')}}
          {{yield (this.sentinelModifier pageIndex) pageIndex to="sentinel"}}
        {{else}}
          <div {{(this.sentinelModifier pageIndex)}}>
          </div>
        {{/if}}
      {{/if}}

      {{#if (this.isPageVisible pageIndex)}}
        {{#each page as |item itemIndex|}}
          {{#if (has-block 'item')}}
            {{yield item pageIndex itemIndex to="item"}}
          {{else}}
            {{yield item pageIndex itemIndex}}
          {{/if}}
        {{/each}}
      {{/if}}
    {{/each}}

    {{#if @paginator.hasMore}}
      {{#if (has-block "loading")}}
        {{! use the sentinel block when you need an entirely different tag such as <tr> or <li>}}
        {{yield (this.loadingModifier) to="loading"}}
      {{else}}
        <div class="loading" {{this.loadingModifier}}>
          <LoadingIndicator />
        </div>
      {{/if}}
    {{else if (and (eq @paginator.allItems.length 0) (has-block "empty"))}}
      {{yield to="empty"}}
    {{/if}}
  </template>
}
