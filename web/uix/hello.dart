library uix.example.hello.main;

import 'dart:html' as html;
import 'package:uix/uix.dart';

class Main extends Component<String> {
  init() {
    data = 'anonymous';
    element.onClick.matches('.sendBtn').listen((_) {
      data = data == 'World' ? 'Earth' : 'World';
      invalidate();
    });
  }

  updateView() {
    print('>>> updateView');
    var sw = new Stopwatch()..start();
    updateRoot(vRoot()([
      vText('Hello ${data}'),
      vElement('button', type: 'sendBtn')('Send')
    ]));
    print('>>> sw: ${(sw..stop()).elapsedMicroseconds}');
  }
}

main() {
  initUix();

  injectComponent(new Main(), html.document.body);
}
