@TestOn('browser')
library tests.fragments;

import 'package:lambda/if.dart';
import 'package:lambda/foreach.dart';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi(uses: const [If, For])

@View('<div><% If(visible) %><span/><% /If %></div>')
class IfFragment {
  static ViewNode viewFactory() => null;

  bool visible = false;
}

@View('''
<div>
  <% For(items -> item) %>
    <span>{{item}}</span>
  <% /For %>
</div>
''')
class ForFragment {
  static ViewNode viewFactory() => null;

  final items = new TrackList.from([1]);
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
}
