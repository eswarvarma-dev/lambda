library lambda.parser.test;

import 'package:test/test.dart';
import 'package:lambda/src/transform/parser.dart';

main() {
  group('parse', () {
    group('basic', () {
      parserTest('plain text', 'abc', (Template tmpl) {
        PlainText ptxt = tmpl.children.single;
        expect(ptxt.text, 'abc');
      });

      parserTest('self-closing HTML element', '<div/>', (Template tmpl) {
        HtmlElement elem = tmpl.children.single;
        expect(elem.tag, 'div');
        expect(elem.children, isEmpty);
      });

      parserTest('HTML element', '<div></div>', (Template tmpl) {
        HtmlElement elem = tmpl.children.single;
        expect(elem.tag, 'div');
        expect(elem.children, isEmpty);
      });

      parserTest('self-closing component element', '<Foo/>', (Template tmpl) {
        ComponentElement elem = tmpl.children.single;
        expect(elem.type, 'Foo');
        expect(elem.children, isEmpty);
      });

      parserTest('component element', '<Bar></Bar>', (Template tmpl) {
        ComponentElement elem = tmpl.children.single;
        expect(elem.type, 'Bar');
        expect(elem.children, isEmpty);
      });

      parserTest('text interpolation', '{{foo.bar}}', (Template tmpl) {
        TextInterpolation txti = tmpl.children.single;
        expect(txti.expression, 'foo.bar');
      });
    });

    group('mixed sequences', () {
      parserTest('element + plain text', '<a/>b', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as HtmlElement).tag, 'a');
        expect((tmpl.children[1] as PlainText).text, 'b');
      });

      parserTest('plain text + element', 'a<b/>', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as PlainText).text, 'a');
        expect((tmpl.children[1] as HtmlElement).tag, 'b');
      });

      parserTest('text interpolation + plain text', '{{a}}b', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as TextInterpolation).expression, 'a');
        expect((tmpl.children[1] as PlainText).text, 'b');
      });

      parserTest('plain text + text interpolation', 'a{{b}}', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as PlainText).text, 'a');
        expect((tmpl.children[1] as TextInterpolation).expression, 'b');
      });

      parserTest('element + text interpolation', '<a/>{{b}}', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as HtmlElement).tag, 'a');
        expect((tmpl.children[1] as TextInterpolation).expression, 'b');
      });

      parserTest('text interpolation + element', '{{a}}<b/>', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as TextInterpolation).expression, 'a');
        expect((tmpl.children[1] as HtmlElement).tag, 'b');
      });

      parserTest('all-in-one', '<div/>a{{b}}c<div/>', (Template tmpl) {
        expect(tmpl.children, hasLength(5));
        expect((tmpl.children[0] as HtmlElement).tag, 'div');
        expect((tmpl.children[1] as PlainText).text, 'a');
        expect((tmpl.children[2] as TextInterpolation).expression, 'b');
        expect((tmpl.children[3] as PlainText).text, 'c');
        expect((tmpl.children[4] as HtmlElement).tag, 'div');
      });
    });

    group('nested', () {
      parserTest('element > plain text', '<a>b</a>', (Template tmpl) {
        expect(tmpl.children, hasLength(1));
        HtmlElement elem = tmpl.children[0];
        expect(elem.tag, 'a');
        expect((elem.children[0] as PlainText).text, 'b');
      });
      parserTest('element > elements', '<a><b/>{{c}}<D/></a>', (Template tmpl) {
        expect(tmpl.children, hasLength(1));
        HtmlElement elem = tmpl.children[0];
        expect(elem.tag, 'a');
        expect((elem.children[0] as HtmlElement).tag, 'b');
        expect((elem.children[1] as TextInterpolation).expression, 'c');
        expect((elem.children[2] as ComponentElement).type, 'D');
      });
    });

    group('attributes', () {
      parserTest('one', '<div id="greeting" />', (Template tmpl) {
        var attrs = tmpl.children.single.attributesAndProps;
        expect(attrs, hasLength(1));
        var attr = attrs[0];
        expect(attr.name, 'id');
        expect(attr.value, 'greeting');
      });

      parserTest('many', '<div a="b" c=\'d\' e="f" />', (Template tmpl) {
        var attrs = tmpl.children.single.attributesAndProps;
        expect(attrs, hasLength(3));

        Attribute attr = attrs[0];
        expect(attr.name, 'a');
        expect(attr.value, 'b');

        attr = attrs[1];
        expect(attr.name, 'c');
        expect(attr.value, 'd');

        attr = attrs[2];
        expect(attr.name, 'e');
        expect(attr.value, 'f');
      });
    });

    group('property binding', () {
      parserTest('one', '<div [a]="b" />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(1));
        Prop prop = props[0];
        expect(prop.property, 'a');
        expect(prop.expression, 'b');
      });

      parserTest('many', '<div [a]="b" [c]=\'d\' />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(2));

        Prop prop = props[0];
        expect(prop.property, 'a');
        expect(prop.expression, 'b');

        prop = props[1];
        expect(prop.property, 'c');
        expect(prop.expression, 'd');
      });
    });

    group('attributes and property bindings', () {
      parserTest('mixed', '<div a="b" [c]="d" e="f" [g]="h" />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(4));

        Attribute attr = props[0];
        expect(attr.name, 'a');
        expect(attr.value, 'b');

        Prop prop = props[1];
        expect(prop.property, 'c');
        expect(prop.expression, 'd');

        attr = props[2];
        expect(attr.name, 'e');
        expect(attr.value, 'f');

        prop = props[3];
        expect(prop.property, 'g');
        expect(prop.expression, 'h');
      });
    });
  });

  group('highlightLocation_', () {
    test('should highlight location', () {
      expect(highlightLocation_(
'''
line1
line2
line3''', 2, 4),
'''
line1
line2
   ^
line3
''');
    });
  });
}

parserTest(String description, String source, testFn(Template tmpl)) {
  test('should parse ${description}', () {
    testFn(parse(source));
  });
}
