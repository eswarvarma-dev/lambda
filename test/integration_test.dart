library lambda.integration.test;

import 'package:guinness/guinness.dart';
import 'package:lambda/lambda.dart';

main() {
  describe('lambda', () {
    it('should compose components', () {
      expect(new ItemList().render())
        .toEqual('<div><div>foo</div><div>bar</div><div>baz</div></div>');
    });
  });
}

class ItemList extends Component {
  final items = ['foo', 'bar', 'baz'];

  Node render() {
    return div(items.map((item) => new Item(item).render()));
  }
}

class Item extends Component {
  final item;

  Item(this.item);

  Node render() {
    return div([text(item)]);
  }
}
