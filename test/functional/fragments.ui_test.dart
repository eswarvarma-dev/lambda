@TestOn('browser')
library tests.fragments;

import 'package:lambda/if.dart';
import 'package:lambda/foreach.dart';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi(uses: const [If, For])

@View('<div>{% If(visible) %}<span/>{% /If %}</div>')
class IfFragment {
  static ViewNode viewFactory() => null;

  bool visible = false;
}

@View('''
<div>
  {% For(items -> item) %}
    <span>{{item}}</span>
  {% /For %}
</div>
''')
class ForFragment {
  static ViewNode viewFactory() => null;

  final items = new TrackList.from([1]);
}

@View('''
<table>
  {% For(rows -> row) %}
    <tr>
      <th>{{row.id}}</th>
      {% For(row.cells -> cell) %}
        <td>{{row.id}}{{cell}}</td>
      {% /For %}
    </tr>
  {% /For %}
</table>
''')
class NestedFragments {
  static ViewNode viewFactory() => null;

  final rows = [
    new Row(1, ['a', 'b']),
    new Row(2, ['c', 'd']),
  ];
}

class Row {
  int id;
  List<String> cells;
  Row(this.id, this.cells);
}

main() {
  group('if fragment', () {
    ViewNode view;

    setUp(() {
      view = IfFragment.viewFactory();
    });

    test('should build', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<if-fragment><div><!----></div></if-fragment>');
    });

    test('should show and hide content', () {
      view.build();
      IfFragment ctrl = view.context;
      ctrl.visible = true;
      view.update();
      expect(view.hostElement.outerHtml,
          '<if-fragment><div><span></span><!----></div></if-fragment>');

      ctrl.visible = false;
      view.update();
      expect(view.hostElement.outerHtml,
          '<if-fragment><div><!----></div></if-fragment>');
    });
  });

  group('for fragment', () {
    ViewNode view;

    setUp(() {
      view = ForFragment.viewFactory();
    });

    test('should build', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<for-fragment><div><!----></div></for-fragment>');
    });

    test('should show correct content', () {
      view.build();
      ForFragment ctrl = view.context;
      view.update();
      expect(view.hostElement.outerHtml,
          '<for-fragment><div><span>1</span><!----></div></for-fragment>');

      ctrl.items.add(2);
      view.update();
      expect(view.hostElement.outerHtml,
          '<for-fragment><div><span>1</span><span>2</span><!----></div></for-fragment>');

      ctrl.items.clear();
      view.update();
      expect(view.hostElement.outerHtml,
          '<for-fragment><div><!----></div></for-fragment>');
    });
  });

  group('nested fragments', () {
    ViewNode view;

    setUp(() {
      view = NestedFragments.viewFactory();
    });

    test('should have access to local variables', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
          '<nested-fragments>'
            '<table>'
              '<tr><th>1</th><td>1a</td><td>1b</td><!----></tr>'
              '<tr><th>2</th><td>2c</td><td>2d</td><!----></tr>'
              '<!---->'
            '</table>'
          '</nested-fragments>');
    });
  });
}
