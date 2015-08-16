library lambda.template_compiler.test;

import 'package:test/test.dart';
import 'package:lambda/transformer.dart';

main() {
  group('TemplateCompiler', () {
    compileTest(
      'primitive template',
      '<div>hello</div>',
      """ vElement('div' ) ( vText('''hello''') )"""
    );

    compileTest(
      'primitive template with nested nodes',
      '<div><span>hello</span>, <span>world</span></div>',
      """ vElement('div' ) ("""
        """ vElement('span' ) ( vText('''hello''') ) ,"""
        """ vText(''', ''') ,"""
        """ vElement('span' ) ( vText('''world''') ) )"""
    );

    compileTest(
      'text interpolation',
      '<div>{{greeting}}</div>',
      """ vElement('div' ) ( vText('''\${context.greeting}''') )"""
    );

    compileTest(
      'multiple text interpolations in same text node',
      '<div>{{greeting}}, {{person}}</div>',
      """ vElement('div' ) ( vText('''\${context.greeting}, \${context.person}''') )"""
    );

    compileTest(
      'text interpolations in different nodes',
      '<div><span>{{greeting}},</span><span>{{person}}</span></div>',
      """ vElement('div' ) ("""
        """ vElement('span' ) ( vText('''\${context.greeting},''') ) ,"""
        """ vElement('span' ) ( vText('''\${context.person}''') ) )"""
    );

    compileTest(
      'child component',
      '<Child/>',
      """ vComponent(Child.viewFactory )"""
    );

    compileTest(
      'nested child component',
      '<div><Child/></div>',
      """ vElement('div' ) ("""
        """ vComponent(Child.viewFactory ) )"""
    );

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
    expect(compiler.compileVirtualTreeForTesting(), expectation);
  });
}
