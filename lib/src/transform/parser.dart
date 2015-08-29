/// Parses Lambda templates.
library lambda.parser;

import 'ast.dart';
export 'ast.dart';
import 'package:petitparser/petitparser.dart';

Template parse(String source) {
  Parser p = new LambdaTemplateGrammar();
  Result result = p.parse(source);
  if (result.isFailure) {
    throw result;
  } else {
    return result.value;
  }
}

class LambdaTemplateGrammar extends GrammarParser {
  LambdaTemplateGrammar() : super(new LambdaTemplateGrammarDefinition());
}

class LambdaTemplateGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(template).end();

  template() => ref(content).map((Iterable rootNodes) {
    return new Template()..children.addAll(rootNodes);
  });

  content() => (ref(htmlElement) | ref(plainText)).star();

  htmlElement() => char('<')
    .seq(ref(htmlElementName))
    // TODO: parse attributes & property bindings
    .seq(
      string('/>')  // self-closing element, e.g. <div/>
      .or(  // element with content
        char('>')
        .seq(ref(content))
        .seq(string('</'))
        .seq(ref(htmlElementName))
        .seq(char('>'))
      ))
    .map((List tokens) {
      return new HtmlElement()
        ..tag = tokens[1];
    });

  htmlElementName() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  identifierNameChar() => pattern('a-zA-Z');

  // TODO: handle HTML entities
  plainText() => plainTextCharacter()
      .plus()
      .flatten()
      .map((String textContent) {
    return new PlainText()..text = textContent;
  });

  plainTextCharacter() =>
      predicate(1, (input) => input != '<', 'illegal plain text character');
}
