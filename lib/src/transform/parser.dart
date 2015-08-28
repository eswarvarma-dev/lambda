/// Parses Lambda templates.
library lambda.parser;

import 'ast.dart';
import 'package:petitparser/petitparser.dart';

Template parse(String source) {
  Parser p = new LambdaTemplateGrammar();
  p.parse(source);
  // TODO: finish implementation
}

class LambdaTemplateGrammar extends GrammarParser {
  LambdaTemplateGrammar() : super(new LambdaTemplateGrammarDefinition());
}

class LambdaTemplateGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(template).end();

  template() =>
      ref(htmlElement)
    | ref(componentElement)
    | ref(textInterpolation)
    | ref(plainText);

}
