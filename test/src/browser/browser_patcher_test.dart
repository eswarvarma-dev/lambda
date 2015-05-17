@TestOn('dartium')

library lambda.test.browser_patcher;

import 'dart:html' as dom;
import 'package:test/test.dart';
import 'package:lambda/browser.dart';

main() {
  group('BrowserPatcher', () {
    dom.Element host;
    BrowserPatcher patcher;

    setUp(() {
      host = new dom.DivElement();
      patcher = new BrowserPatcher.adopt(host);
    });

    test('should bootstrap something from nothing', () {
      var sample = div({},
        tdiv('Hello'),
        tdiv(' '),
        tdiv('World!')
      );
      var patch = new ElementPatch(DIV_TYPE.typeIndex, 0, null, [sample], 0);
      patcher.apply(patch);
      expect(host.innerHtml,
          '<div><div>Hello</div><div> </div><div>World!</div></div>');
    });
  });
}
