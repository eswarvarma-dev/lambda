@TestOn('browser')
library tests.fragments;

import 'package:lambda/if.dart';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

@View('<div><% If(visible) %><% /If %></div>')
class WithFragment {
  static ViewNode viewFactory() => null;
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
          '<withfragment><div><template></template></div></withfragment>');
    });
  });
}
