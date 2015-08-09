library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class Button {
  String title;
}

main() {
  initUix();
  injectComponent(new Button$Component(), document.querySelector('#app-host'));
}
