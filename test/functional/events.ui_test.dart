@TestOn('browser')
library tests.events;

import 'dart:html';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

@View('<button (click)="clicked" />')
class ClickTest {
  static ViewNode viewFactory() => null;

  int clickCounter = 0;

  void clicked(_) {
    clickCounter++;
  }
}

main() {
  group('click', () {
    ViewNode<ClickTest> view;

    setUp(() {
      view = ClickTest.viewFactory();
    });

    test('should run handler statement once per event', () {
      view.build();
      ClickTest ctrl = view.context;
      expect(ctrl.clickCounter, 0);
      ButtonElement btn = view.hostElement.children.single;
      btn.click();
      expect(ctrl.clickCounter, 1);
      btn.click();
      expect(ctrl.clickCounter, 2);
    });
  });
}
