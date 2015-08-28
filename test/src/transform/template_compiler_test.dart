library lambda.compiler.test;

import 'package:test/test.dart';
import 'package:lambda/transformer.dart';
import 'package:dart_style/dart_style.dart';

final formatter = new DartFormatter();

String fmt(String code) => formatter.format(code);

main() {
  group('TemplateCompiler', () {
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

    // compileTest(
    //   'text interpolation',
    //   '<div>{{greeting}}</div>',
    //   """
    //   beginElement('div' );
    //   endElement();
    //   """
    // );
    //
    // compileTest(
    //   'multiple text interpolations in same text node',
    //   '<div>{{greeting}}, {{person}}</div>',
    //   """ vElement('div' ) ( vText('''\${context.greeting}, \${context.person}''') )"""
    // );
    //
    // compileTest(
    //   'text interpolations in different nodes',
    //   '<div><span>{{greeting}},</span><span>{{person}}</span></div>',
    //   """ vElement('div' ) ("""
    //     """ vElement('span' ) ( vText('''\${context.greeting},''') ) ,"""
    //     """ vElement('span' ) ( vText('''\${context.person}''') ) )"""
    // );
    //
    // compileTest(
    //   'child component',
    //   '<Child/>',
    //   """ vComponent(Child.viewFactory )"""
    // );
    //
    // compileTest(
    //   'nested child component',
    //   '<div><Child/></div>',
    //   """ vElement('div' ) ("""
    //     """ vComponent(Child.viewFactory ) )"""
    // );

    // compileTest(
    //   'data binding',
    //   '<Button [title]="_actionName" />',
    //   """ vComponent"""
    // );
  });
}

void compileTest(String description, String template, String expectation) {
  test(description, () {
    final compiler = new TemplateCompiler('Foo', template);
    final fmtExpected =
    fmt('''
    main() {
      ${expectation}
    }
    ''').trim();
    final fmtActual = fmt('''
    main() {
      ${compiler.compileVirtualTreeForTesting_()}
    }
    ''').trim();
    expect(fmtActual, fmtExpected);
  });
}
