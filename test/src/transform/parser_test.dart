library lambda.parser.test;

import 'package:test/test.dart';
import 'package:lambda/src/transform/parser.dart';

main() {
  group('parse', () {
    parserTest('plain text', 'abc', (Template tmpl) {
      expect(tmpl.children, hasLength(1));
      PlainText ptxt = tmpl.children.single;
      expect(ptxt.text, 'abc');
    });

    parserTest('self-closing HTML element', '<div/>', (Template tmpl) {
      expect(tmpl.children, hasLength(1));
      HtmlElement elem = tmpl.children.single;
      expect(elem.tag, 'div');
    });

    parserTest('HTML element', '<div></div>', (Template tmpl) {
      expect(tmpl.children, hasLength(1));
      HtmlElement elem = tmpl.children.single;
      expect(elem.tag, 'div');
    });
  });
}

parserTest(String description, String source, testFn(Template tmpl)) {
  test('should parse ${description}', () {
    testFn(parse(source));
  });
}
