// TODO: implement injectable GreentingService
// TODO: implement "red" decorator
library lambda.examples.hello;

import 'dart:html';
import 'package:lambda/lambda.dart';

@LambdaUi()

@View('''
<div class="greeting">
  {{greeting}} <span> world</span>!
</div>
<button class="changeButton" (click)="changeGreeting">
  change greeting
</button>
''')
class HelloApp {
  static ViewNode viewFactory() => null;

  String greeting = 'hello';

  void changeGreeting(_) {
    this.greeting = greeting == 'howdy' ? 'hello' : 'howdy';
  }
}

main() {
  final app = updateUiAutomatically(HelloApp.viewFactory);
  document.getElementById('app').append(app.hostElement);
}
