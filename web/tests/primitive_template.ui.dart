library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div id="greeting">hello</div>')
class Button {}

main() {
  initUix();
  injectComponent(new Button$View(), document.querySelector('#app-host'));
}
