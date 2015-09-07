@TestOn('browser')
library tests.basic_component;

import 'dart:html';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class PrimitiveComponent {
  static ViewNode viewFactory() => null;
}

@View('<div>{{greeting}}</div>')
class WithTextInterpolation {
  static ViewNode viewFactory() => null;

  String greeting = 'hello';
}

@View('<div [id]="id" />')
class WithProp {
  static ViewNode viewFactory() => null;

  String id = 'id1';
}

@View('<button (click)="clicked" />')
class WithEvent {
  static ViewNode viewFactory() => null;

  int clickCounter = 0;

  void clicked(_) {
    clickCounter++;
  }
}

main() {
  group('primitive component', () {
    ViewNode view;

    setUp(() {
      view = PrimitiveComponent.viewFactory();
    });

    test('should build', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<primitive-component><div>hello</div></primitive-component>');
    });

    test('should update', () {
      view
        ..build()
        ..update();
    });
  });

  group('component with text interpolation', () {
    ViewNode view;

    setUp(() {
      view = WithTextInterpolation.viewFactory();
    });

    test('should build with no data', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<with-text-interpolation><div> </div></with-text-interpolation>');
    });

    test('should update with some data', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
          '<with-text-interpolation><div>hello</div></with-text-interpolation>');
    });
  });

  group('component with prop', () {
    ViewNode<WithProp> view;

    setUp(() {
      view = WithProp.viewFactory();
    });

    test('should build with no data', () {
      view.build();
      expect(view.hostElement.outerHtml,
          '<with-prop><div></div></with-prop>');
    });

    test('should update with some data', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
          '<with-prop><div id="id1"></div></with-prop>');

      WithProp ctrl = view.context;
      ctrl.id = 'id2';
      expect(view.hostElement.outerHtml,
          '<with-prop><div id="id1"></div></with-prop>');
      view.update();
      expect(view.hostElement.outerHtml,
          '<with-prop><div id="id2"></div></with-prop>');
    });
  });

  group('component with event', () {
    ViewNode<WithEvent> view;

    setUp(() {
      view = WithEvent.viewFactory();
    });

    test('should capture events', () {
      view.build();
      WithEvent ctrl = view.context;
      expect(ctrl.clickCounter, 0);
      ButtonElement btn = view.hostElement.children.single;
      btn.click();
      expect(ctrl.clickCounter, 1);
      btn.click();
      expect(ctrl.clickCounter, 2);
    });
  });
}
