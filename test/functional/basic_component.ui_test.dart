@TestOn('browser')
library tests.basic_component;

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

@View('<Child [foo]="bar" />')
class Parent {
  static ViewNode viewFactory() => null;

  String bar = 'a';
}

@View('<div>{{foo}}</div>')
class Child {
  static ViewNode viewFactory() => null;

  String foo;
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
          '<primitive-component><div id="greeting">hello</div></primitive-component>');
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

  group('nested components', () {
    ViewNode<Parent> view;

    setUp(() {
      view = Parent.viewFactory();
    });

    test('should contain child', () {
      view.build();
      expect(view.hostElement.outerHtml,
        '<parent><child><div> </div></child></parent>');
    });

    test('should update child', () {
      view.build();
      view.update();
      expect(view.hostElement.outerHtml,
        '<parent><child><div>a</div></child></parent>');

      view.context.bar = 'b';
      view.update();
      expect(view.hostElement.outerHtml,
        '<parent><child><div>b</div></child></parent>');
    });
  });
}
