library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div>{{title}}</div>')
class Button {
  String title;
  Button(this.title);
}

main() {
  initUix();
  final rootCmp = new Button$View()
    ..context = new Button('Save');
  injectComponent(rootCmp, document.querySelector('#app-host'));
}
