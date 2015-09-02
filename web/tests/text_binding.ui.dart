library tests.simple_component;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('<div>{{title}}</div>')
class Button {
  // This is implemented by transformer
  static ViewObject viewFactory() => null;

  String title;

  Button();
}

main() {
  final hostElement = document.querySelector('#app-host');
  mountView(Button.viewFactory()
    ..context.title = 'Save', onto: hostElement);
}
