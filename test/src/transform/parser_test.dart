@TestOn('vm')
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

      group('HTML element', () {
        [
          'div', 'h1', 'a', 'hello-world'
        ].forEach((String tag) {
          parserTest('self-closing $tag', '<$tag/>', (Template tmpl) {
            HtmlElement elem = tmpl.children.single;
            expect(elem.tag, tag);
            expect(elem.children, isEmpty);
          });

          parserTest('$tag', '<$tag></$tag>', (Template tmpl) {
            HtmlElement elem = tmpl.children.single;
            expect(elem.tag, tag);
            expect(elem.children, isEmpty);
          });
        });
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
        expectExpression(txti.expression, 'foo.bar');
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
        expectExpression((tmpl.children[0] as TextInterpolation).expression, 'a');
        expect((tmpl.children[1] as PlainText).text, 'b');
      });

      parserTest('plain text + text interpolation', 'a{{b}}', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as PlainText).text, 'a');
        expectExpression((tmpl.children[1] as TextInterpolation).expression, 'b');
      });

      parserTest('element + text interpolation', '<a/>{{b}}', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expect((tmpl.children[0] as HtmlElement).tag, 'a');
        expectExpression((tmpl.children[1] as TextInterpolation).expression, 'b');
      });

      parserTest('text interpolation + element', '{{a}}<b/>', (Template tmpl) {
        expect(tmpl.children, hasLength(2));
        expectExpression((tmpl.children[0] as TextInterpolation).expression, 'a');
        expect((tmpl.children[1] as HtmlElement).tag, 'b');
      });

      parserTest('all-in-one', '<div/>a{{b}}c<div/>', (Template tmpl) {
        expect(tmpl.children, hasLength(5));
        expect((tmpl.children[0] as HtmlElement).tag, 'div');
        expect((tmpl.children[1] as PlainText).text, 'a');
        expectExpression((tmpl.children[2] as TextInterpolation).expression, 'b');
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
        expectExpression((elem.children[1] as TextInterpolation).expression, 'c');
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

      parserTest('many', '<div a="b" c="d" e="f" />', (Template tmpl) {
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

      parserTest('no value', '<div autofocus />', (Template tmpl) {
        Attribute attr = tmpl.children.single.attributesAndProps.single;
        expect(attr.name, 'autofocus');
        expect(attr.value, '');
      });

      parserTest(
          'no value followed by other',
          '<input autofocus disabled />'
          '<input autofocus (click)="stmt" />'
          '<input autofocus id="123" />'
          '<input autofocus [hidden]="expr" />',
          (Template tmpl) {
            tmpl.children.forEach((child) {
              Attribute attr = child.attributesAndProps[0];
              expect(attr.name, 'autofocus');
              expect(attr.value, '');
            });
          });

      parserTest(
          'no value preceded by other',
          '<input disabled autofocus />'
          '<input (click)="stmt" autofocus />'
          '<input id="123" autofocus />'
          '<input [hidden]="expr" autofocus />',
          (Template tmpl) {
            tmpl.children.forEach((child) {
              Attribute attr = child.attributesAndProps[1];
              expect(attr.name, 'autofocus');
              expect(attr.value, '');
            });
          });
    });

    group('property binding', () {
      parserTest('one', '<div [a]="b" />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(1));
        Prop prop = props[0];
        expect(prop.property, 'a');
        expectExpression(prop.expression, 'b');
      });

      parserTest('many', '<div [a]="b" [c]="d" />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(2));

        Prop prop = props[0];
        expect(prop.property, 'a');
        expectExpression(prop.expression, 'b');

        prop = props[1];
        expect(prop.property, 'c');
        expectExpression(prop.expression, 'd');
      });
    });

    group('events', () {
      parserTest('one', '<div (a)="b" />', (Template tmpl) {
        Event event = tmpl.children.single.attributesAndProps.single;
        expect(event.type, 'a');
        expect(event.statement, 'b');
      });
    });

    group('attributes, props and events', () {
      parserTest('mixed', '<div a="b" [c]="d" (e)="f" [g]="h" />', (Template tmpl) {
        var props = tmpl.children.single.attributesAndProps;
        expect(props, hasLength(4));

        Attribute attr = props[0];
        expect(attr.name, 'a');
        expect(attr.value, 'b');

        Prop prop = props[1];
        expect(prop.property, 'c');
        expectExpression(prop.expression, 'd');

        Event event = props[2];
        expect(event.type, 'e');
        expect(event.statement, 'f');

        prop = props[3];
        expect(prop.property, 'g');
        expectExpression(prop.expression, 'h');
      });
    });

    group('fragment controller', () {
      parserTest('simple', '{% If (condition) %}<div/>{% /If %}', (Template tmpl) {
        Fragment frag = tmpl.children.single;
        expect(frag, isNotNull);
        expect(frag.type, 'If');
        expectExpression(frag.inputExpression, 'condition');
        expect(frag.outVars, isEmpty);
        expect(frag.childNodes, hasLength(1));
        expect(frag.children, hasLength(1));
      });

      test('should validate closing tags', () {
        try {
          parse('{% If (condition) %}<div/>{% /Fi %}');
          fail('should have thrown');
        } catch (e) {
          expect(e, 'Closing fragment {% /Fi %} does not match'
              ' opening fragment {% If %}.');
        }
      });

      parserTest(
          'output variable',
          '{% For (items -> item) %}{% /For %}',
          (Template tmpl) {
        Fragment frag = tmpl.children.single;
        expectExpression(frag.inputExpression, 'items');
        expect(frag.outVars, ['item']);
      });
    });

    group('decorator', () {
      parserTest(
        'simple',
        ['{# Decor #}', '{# Decor() #}'],
        (Template tmpl) {
          Decorator decor = tmpl.children.single;
          expect(decor.type, 'Decor');
          expect(decor.props, isEmpty);
        }
      );

      parserTest(
        'prop',
        '{# Decor(foo: bar) #}',
        (Template tmpl) {
          Decorator decor = tmpl.children.single;
          expect(decor.type, 'Decor');
          final props = decor.props;
          expect(props, hasLength(1));
          expect(props.single.property, 'foo');
          expectExpression(props.single.expression, 'bar');
        }
      );

      parserTest(
        'props',
        '{# Decor(foo: bar, baz: qux.quux) #}',
        (Template tmpl) {
          Decorator decor = tmpl.children.single;
          expect(decor.type, 'Decor');
          final props = decor.props;
          expect(props, hasLength(2));

          expect(props[0].property, 'foo');
          expectExpression(props[0].expression, 'bar');

          expect(props[1].property, 'baz');
          expectExpression(props[1].expression, 'qux.quux');
        }
      );
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

parserTest(String description, dynamic sources, testFn(Template tmpl)) {
  if (sources is String) {
    sources = [sources];
  }
  assert(sources is Iterable);
  for (String source in sources) {
    test('should parse ${description}', () {
      testFn(parse(source));
    });
  }
}

expectExpression(Expression expr, String exprString) {
  expect(expr.toString(), exprString);
}
