@TestOn('browser')
library lambda.tests.decorators;

import 'dart:html';
import 'package:lambda/lambda.dart';
import 'package:test/test.dart';

@LambdaUi()

class Highlight extends Decorator {
  Highlight(Element target) : super(target);

  set on(bool isOn) {
    if (isOn != null && isOn) {
      this.target.style.border = '1px solid black';
    } else {
      this.target.style.border = 'none';
    }
  }
}

@View('''
{# Highlight(on: highlight) #}
<div id="target">hello</div>
''')
class DecoratorTest {
  static ViewNode viewFactory() => null;
  bool highlight;
}

main() {
  group('click', () {
    ViewNode<DecoratorTest> view;

    setUp(() {
      view = DecoratorTest.viewFactory();
    });

    test('should run handler statement once per event', () {
      view.build();
      final Element target = view.hostElement.querySelector('#target');
      expect(target.style.border, '');
      view.context.highlight = true;
      view.update();
      expect(target.style.border, '1px solid black');
    });
  });
}
