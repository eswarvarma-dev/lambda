@TestOn('vm')
library lambda.compiler.test;

import 'package:test/test.dart';
import 'package:lambda/src/transform/compiler.dart';
import 'package:lambda/src/transform/parser.dart';
import 'package:dart_style/dart_style.dart';

final formatter = new DartFormatter();

String fmt(String code) => formatter.format(code).trim();

main() {
  group('TemplateCompiler', () {
    test('should compose a view object', () {
      final actual = new TemplateCompiler('Foo', '<div/>').compile();
      expect(fmt(actual), fmt('''
        class Foo\$View extends ViewNodeBuilder<Foo> {
          @override
          build() {
            final context = new Foo();
            beginHost(\'Foo\');
            beginElement(\'div\');
            endElement();
            endHost();
          }
        }
      '''));
    });
  });

  group('BuildMethodVisitor', () {
    compileTest(
      'primitive template',
      '<div>hello</div>',
      """
      beginElement('div');
      addText('''hello''');
      endElement();
      """
    );

    compileTest(
      'primitive template with nested nodes',
      '<div><span>hello</span>, <span>world</span></div>',
      """
      beginElement('div');
      beginElement('span');
      addText('''hello''');
      endElement();
      addText(''', ''');
      beginElement('span');
      addText('''world''');
      endElement();
      endElement();
      """
    );

    compileTest(
      'text interpolation',
      '<div>{{greeting}}</div>',
      """
      beginElement('div' );
      addTextInterpolation();
      endElement();
      """
    );

    compileTest(
      'multiple text interpolations in same text node',
      '<div>{{greeting}}, {{person}}</div>',
      """
      beginElement('div' );
      addTextInterpolation();
      addText(''', ''' );
      addTextInterpolation();
      endElement();
      """
    );

    compileTest(
      'text interpolations in different nodes',
      '<div><span>{{greeting}},</span><span>{{person}}</span></div>',
      """
      beginElement('div' );
      beginElement('span' );
      addTextInterpolation();
      addText(''',''' );
      endElement();
      beginElement('span' );
      addTextInterpolation();
      endElement();
      endElement();
      """
    );

    compileTest(
      'child component',
      '<Child/>',
      """
      beginChild(Child.viewFactory());
      endElement();
      """
    );

    compileTest(
      'nested child component',
      '<div><Child/></div>',
      """
      beginElement('div' );
      beginChild(Child.viewFactory());
      endElement();
      endElement();
      """
    );
  });
}

void compileTest(String description, String source, String expectation) {
  test(description, () {
    final buildVisitor = new BuildMethodVisitor('Foo');
    parse(source).accept(buildVisitor);
    final fmtExpected = fmt('''
    @override
    build() {
      final context = new Foo();
      beginHost('Foo');
      ${expectation.trim()}
      endHost();
    }
    ''');
    final fmtActual = fmt(buildVisitor.code);
    expect(fmtActual, fmtExpected);
  });
}
