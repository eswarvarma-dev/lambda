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
}
