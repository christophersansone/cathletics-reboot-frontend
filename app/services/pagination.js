import Service from '@ember/service';
import { service } from '@ember/service';
import Paginator from 'frontend/utils/paginator';

const DEFAULT_PAGE_SIZE = 100;

export default class PaginationService extends Service {
  @service store;

  query(type, queryParams, { pageSize = DEFAULT_PAGE_SIZE } = {}) {
    let paginator = null;
    let nextUrl = null;

    const fetchPage = async (queryParams) => {
      const response = await this.store.query(type, queryParams);
      nextUrl = response.links?.next;
      return response;
    }

    const fetchFirstPage = async () => {
      return await fetchPage(queryParams);
    }

    const fetchNextPage = async () => {
      // we can safely assume that the next URL is a similar URL to the first one,
      // with query params to match the next page -- we don't care what those params are,
      // we just want to craft the request as a store query
      const { searchParams } = new URL(nextUrl);
      return await fetchPage(Object.fromEntries(searchParams));
    }

    paginator = new Paginator(async (pageNumber) => {
      if (pageNumber === 1) {
        return await fetchFirstPage();
      } else if (nextUrl) {
        return await fetchNextPage();
      } else {
        return [];
      }
    }, pageSize);

    return paginator;
  }

  async fetchHasMany(record, relationshipName, { pageSize = DEFAULT_PAGE_SIZE }) {
    const rel = record.hasMany(relationshipName);
    let url = rel.link();
    if (!url) {
      throw new Error(`Relationship "${relationshipName}" on model "${record.modelName}" has no link`);
    }

    const { searchParams } = new URL(url);
    return await this.query(rel.type, Object.fromEntries(searchParams), { pageSize });
  }
}
