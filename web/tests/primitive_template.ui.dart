library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class Button {
  // This is implemented by transformer
  static ViewNode viewFactory() => null;
}

main() {
  final hostElement = document.querySelector('#app-host');
  mountView(Button.viewFactory(), onto: hostElement);
}
