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
            assert(ViewNodeBuilder.isStackEmpty);
            beginHost(\'foo\', new Foo());
            beginElement(\'div\');
            endElement();
            endHost();
          }
          @override
          void update() {
            var _tmp;
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
      _textInterpolationNode1 = addTextInterpolation();
      endElement();
      """
    );

    compileTest(
      'multiple text interpolations in same text node',
      '<div>{{greeting}}, {{person}}</div>',
      """
      beginElement('div' );
      _textInterpolationNode1 = addTextInterpolation();
      addText(''', ''' );
      _textInterpolationNode2 = addTextInterpolation();
      endElement();
      """
    );

    compileTest(
      'text interpolations in different nodes',
      '<div><span>{{greeting}},</span><span>{{person}}</span></div>',
      """
      beginElement('div' );
      beginElement('span' );
      _textInterpolationNode2 = addTextInterpolation();
      addText(''',''' );
      endElement();
      beginElement('span' );
      _textInterpolationNode4 = addTextInterpolation();
      endElement();
      endElement();
      """
    );

    compileTest(
      'child component',
      '<Child/>',
      """
      _child0 = beginChild(Child.viewFactory());
      endElement();
      """
    );

    compileTest(
      'nested child component',
      '<div><Child/></div>',
      """
      beginElement('div' );
      _child1 = beginChild(Child.viewFactory());
      endElement();
      endElement();
      """
    );

    compileTest(
      'fragment',
      '<% For (items -> item) %><div/><% /For %>',
      """
      addFragmentController(_fragment0 = Foo\$View\$Fragment\$0.create());
      """
    );
  });
}

void compileTest(String description, String source, String expectation) {
  test(description, () {
    final buildVisitor = new TemplateBuildMethodVisitor('Foo');
    parse(source)
      ..accept(new TemplateBinder('Foo\$View'))
      ..accept(buildVisitor);
    final fmtExpected = fmt('''
    @override
    build() {
      assert(ViewNodeBuilder.isStackEmpty);
      beginHost('foo', new Foo());
      ${expectation.trim()}
      endHost();
    }
    ''');
    final fmtActual = fmt(buildVisitor.code);
    expect(fmtActual, fmtExpected);
  });
}
