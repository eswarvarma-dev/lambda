@TestOn('browser')
library tests.basic_component;

import 'dart:html';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class BasicComponent {
  static ViewNode viewFactory() => null;
}

main() {
  group('funtional: basic component', () {
    test('should mount component on an element', () {
      var hostElement = new DivElement();
      var view = BasicComponent.viewFactory();
      expect(view, isNotNull);
      mountView(view, onto: hostElement);
    });
  });
}
