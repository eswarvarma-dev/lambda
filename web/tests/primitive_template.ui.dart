library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class Button {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;
}

main() {
  initUix();
  injectComponent(Button.viewFactory(), document.querySelector('#app-host'));
}
