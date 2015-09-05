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
          '<primitivecomponent><div>hello</div></primitivecomponent>');
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
          '<withtextinterpolation><div> </div></withtextinterpolation>');
    });

    test('should update with some data', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
          '<withtextinterpolation><div>hello</div></withtextinterpolation>');
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
          '<withprop><div></div></withprop>');
    });

    test('should update with some data', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
          '<withprop><div id="id1"></div></withprop>');

      WithProp ctrl = view.context;
      ctrl.id = 'id2';
      expect(view.hostElement.outerHtml,
          '<withprop><div id="id1"></div></withprop>');
      view.update();
      expect(view.hostElement.outerHtml,
          '<withprop><div id="id2"></div></withprop>');
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
