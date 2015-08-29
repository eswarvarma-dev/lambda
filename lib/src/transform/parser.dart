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

  content() => (
      ref(htmlElement)
    | ref(componentElement)
    | ref(textInterpolation)
    | ref(plainText)
  ).star();

  textInterpolation() =>
    string('{{')
    .seq(pattern('a-z.A-Z').plus().flatten())  // TODO: accept more
    .seq(string('}}')).map((List tokens) {
      return new TextInterpolation()
        ..expression = tokens[1];
    });

  expression() =>
    (pattern('a-zA-Z').plus())
    .optional(char('.').seq((pattern('a-zA-Z').plus())))
    .flatten();

  htmlElement() => element(ref(htmlElementName), (String name) {
    return new HtmlElement()
      ..tag = name;
  });

  componentElement() => element(ref(componentElementName), (String name) {
    return new ComponentElement()
      ..type = name;
  });

  element(Parser nameParser, Element astNodeFactory(String name)) =>
    char('<')
    .seq(nameParser)
    // TODO: parse attributes & property bindings
    .seq(
      string('/>')  // self-closing element, e.g. <div/>
      .or(  // element with content
        char('>')
        .seq(ref(content))
        .seq(string('</'))
        .seq(nameParser)
        .seq(char('>'))
      ))
    .map((List tokens) {
      return astNodeFactory(tokens[1]);
    });

  // TODO: differentiate between html and component names:
  //   - html tag names may contain "-"
  //   - component names may contain "$" and other Dart identifier characters
  htmlElementName() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  componentElementName() => pattern('A-Z').seq(ref(identifierNameChar).star())
      .flatten();

  identifierNameChar() => pattern('a-zA-Z');  // TODO: accept more

  plainText() => new PlainTextParser()
      .map((String textContent) {
        return new PlainText()..text = textContent;
      });

  plainTextCharacter() =>
      predicate(1, (input) => input != '<', 'illegal plain text character');
}

// TODO: handle HTML entities
class PlainTextParser extends Parser {
  PlainTextParser();

  @override
  Result parseOn(Context context) {
    final buf = new StringBuffer();
    int currPos = context.position;

    Result done() {
      if (buf.length > 0) {
        assert(buf.length == currPos - context.position);
        return context.success(buf.toString(), currPos);
      } else {
        return context.failure('not plain text');
      }
    }

    while (currPos < context.buffer.length) {
      final currChar = context.buffer[currPos];
      if (currChar == '<') {
        return done();
      }
      final nextPos = currPos + 1;
      if (currChar == '{' && nextPos < context.buffer.length) {
        final nextChar = context.buffer[nextPos];
        if (nextChar == '{') {
          return done();
        }
      }
      buf.write(currChar);
      currPos = nextPos;
    }
    return done();
  }

  @override
  Parser copy() => this;  // it's stateless

  @override
  String toString() => 'PlainTextParser';
}
