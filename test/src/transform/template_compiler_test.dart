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
  });
}

void compileTest(String description, String template, String expectation) {
  test(description, () {
    final compiler = new TemplateCompiler('Foo', template);
    expect(compiler.compileBuildBodyForTesting(), expectation);
  });
}
