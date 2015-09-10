@TestOn('browser')
library tests.fragments;

import 'package:lambda/if.dart';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

@View('<div><% If(visible) %><span/><% /If %></div>')
class WithFragment {
  static ViewNode viewFactory() => null;

  bool visible = false;
}

main() {
  group('component with fragment', () {
    ViewNode view;

    setUp(() {
      view = WithFragment.viewFactory();
    });

    test('should build', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<with-fragment><div><!----></div></with-fragment>');
    });

    test('should show and hide content', () {
      view.build();
      WithFragment ctrl = view.context;
      ctrl.visible = true;
      view.update();
      expect(view.hostElement.outerHtml,
          '<with-fragment><div><span></span><!----></div></with-fragment>');

      ctrl.visible = false;
      view.update();
      expect(view.hostElement.outerHtml,
          '<with-fragment><div><!----></div></with-fragment>');
    });
  });
}
