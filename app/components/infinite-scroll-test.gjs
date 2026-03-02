import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import Paginator from 'frontend/utils/paginator';
import InfiniteScroll from 'frontend/components/infinite-scroll';

export default class InfiniteScrollTest extends Component {

  @cached
  get paginator() {
    return new Paginator(async (pageNumber, pageSize) => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      const count = pageNumber > 5 ? 10 : pageSize
      return Array.from({ length: count }, (_, index) => `Item ${(pageNumber-1) * pageSize + index}`);
    });
  }


  <template>
    <InfiniteScroll @paginator={{this.paginator}} @occlude={{true}} as |item|>
      <div style="padding: 2em; border-bottom: 1px solid #eee">
        Item! {{item}}
      </div>
    </InfiniteScroll>
  </template>
}
