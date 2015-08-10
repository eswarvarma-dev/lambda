library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div>{{title}}</div>')
class Button {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  String title;
  Button(this.title);
}

main() {
  initUix();
  final rootCmp = Button.viewFactory()
    ..context = new Button('Save');
  injectComponent(rootCmp, document.querySelector('#app-host'));
}
