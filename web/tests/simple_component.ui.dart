library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div class="button">{{title}}</div>')
class Button {
  String title;
}

main() {
  initUix();
  injectComponent(new Button$Component(), document.querySelector('#app-host'));
}
