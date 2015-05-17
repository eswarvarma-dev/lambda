@TestOn('dartium')

library lambda.test.browser.convenience;

import 'package:lambda/browser.dart';
import 'package:test/test.dart';

main() {
  group('convenience', () {
    test('should have a nice DSL for building HTML', () {
      div({'id': 'main-menu', 'class': 'header'},
        div({'style': 'height: 10px'},
          tdiv('Hello'),
          tdiv('World', {'style': 'font-weight: bold;'})
        )
      );
    });
  });
}
