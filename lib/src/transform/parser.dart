/// Parses Lambda templates.
library lambda.parser;

import 'ast.dart';
export 'ast.dart';
import 'package:petitparser/petitparser.dart';

Template parse(String source) {
  Parser p = new LambdaTemplateGrammar();
  Result result = p.parse(source);
  if (result.isFailure) {
    var location = Token.lineAndColumnOf(source, result.position);
    var line = location[0];
    var column = location[1];
    var highlightedSource = highlightLocation_(source, line, column);
    throw 'Failed to parse template: ${result.message}\n\n${highlightedSource}';
  } else {
    return result.value;
  }
}

String highlightLocation_(String source, int line, int column) {
  assert(line >= 1);
  assert(column >= 1);
  String highlightLine = '${' ' * (column - 1)}^';
  List<String> lines = source.split('\n');
  assert(line <= lines.length);
  final buf = new StringBuffer();
  for (int i = 0; i < lines.length; i++) {
    buf.writeln(lines[i]);
    if (i == line - 1) {
      buf.writeln(highlightLine);
    }
  }
  return buf.toString();
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
    | ref(fragment)
    | ref(decorator)
    | ref(textInterpolation)
    | ref(plainText)
    | ref(space)
  ).star();

  /// Parses text interpolation of the form `{{expression}}`.
  textInterpolation() =>
    string('{{')
    .seq(ref(expression))  // TODO: accept more
    .seq(string('}}')).map((List tokens) {
      return new TextInterpolation()
        ..expression = tokens[1];
    });

  /// Parses a template expression, currently only of the form `foo.bar.baz`.
  expression() =>
    ref(dartVariableName).separatedBy(char('.'))
    .flatten()
    .map(_parseExpression);

  htmlElement() => element(ref(htmlElementName), (String name) {
    return new HtmlElement()
      ..tag = name;
  });

  componentElement() => element(ref(dartClassName), (String name) {
    return new ComponentElement()
      ..type = name;
  });

  attribute() =>
      ref(attributeName)
      .seq(ref(attributeValueAssignment).optional())
      .map((List tokens) {
        return new Attribute(tokens[0], tokens[1] ?? '');
      });
  attributeValueAssignment() =>
      ref(whitespace).star()
      .seq(char('='))
      .seq(ref(whitespace).star())
      .seq(ref(attributeValue))
      .pick(3);

  attributeValue() =>
      ref(attributeValueDouble).or(ref(attributeValueSingle)).pick(1);
  attributeValueDouble() => char('"')
      .seq(new AttributeValueParser('"'))
      .seq(char('"'));
  attributeValueSingle() => char("'")
      .seq(new AttributeValueParser("'"))
      .seq(char("'"));

  prop() =>
    char('[')
    .seq(ref(dartVariableName))
    .seq(char(']'))
    .seq(ref(space).optional())
    .seq(char('='))
    .seq(ref(space).optional())
    .seq(char('"'))
    .seq(ref(expression))
    .seq(char('"'))
    .map((List tokens) {
      return new Prop()
        ..property = tokens[1]
        ..expression = tokens[7];
    });

  event() =>
    char('(')
    .seq(ref(eventType))
    .seq(char(')'))
    .seq(ref(space).optional())
    .seq(char('='))
    .seq(ref(space).optional())
    .seq(ref(attributeValue))
    .map((List tokens) {
      return new Event()
        ..type = tokens[1]
        ..statement = tokens[6];
    });

  attributesAndProps() =>
    ref(space)
    .seq(ref(attribute).or(ref(prop)).or(ref(event)))
    .pick(1)
    .star();

  element(Parser nameParser, Element astNodeFactory(String name)) =>
    char('<')
    .seq(nameParser)
    .seq(ref(attributesAndProps))
    .seq(ref(space).optional())
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
      String name = tokens[1];
      List<DataNode> dataNodes = tokens[2];
      Element elem = astNodeFactory(name);
      elem.attributesAndProps.addAll(dataNodes);
      if (tokens[4] is List) {
        elem.childNodes.addAll(tokens[4][1]);
      }
      return elem;
    });

  fragmentOutputVariables() =>
    ref(space).optional()
    .seq(string('->'))
    .seq(ref(space).optional())
    .seq(ref(dartVariableName))
    .map((List tokens) {
      return [tokens[3]];
    });

  decorator() =>
    string('{#')
    .seq(ref(space).optional())
    .seq(ref(dartClassName))
    .seq(ref(space).optional())
    .seq(ref(decoratorProps).optional())
    .seq(ref(space).optional())
    .seq(string('#}'))
    .map((List tokens) {
      return new Decorator()
        ..type = tokens[2]
        ..props = tokens[4] == null
          ? <Prop>[]
          : tokens[4];
    });

  decoratorProps() =>
    char('(')
    .seq(ref(space).optional())
    .seq(ref(decoratorProp).separatedBy(ref(separator(','))).optional())
    .seq(ref(space).optional())
    .seq(char(')'))
    .map((List tokens) {
      if (tokens[2] == null) return const <Prop>[];
      return tokens[2].where((p) => p is Prop).toList();
    });

  decoratorProp() =>
    ref(dartVariableName)
    .seq(ref(separator(':')))
    .seq(ref(expression))
    .map((List tokens) {
      return new Prop()
        ..property = tokens[0]
        ..expression = tokens[2];
    });

  fragment() =>
    string('{%')
    .seq(ref(space).optional())
    .seq(ref(dartClassName))
    .seq(ref(space).optional())
    .seq(char('('))
    .seq(ref(expression))
    .seq(ref(fragmentOutputVariables).optional())
    .seq(char(')'))
    .seq(ref(space).optional())
    .seq(string('%}'))
    .seq(ref(content))
    .seq(string('{%'))
    .seq(ref(space).optional())
    .seq(char('/'))
    .seq(ref(dartClassName))
    .seq(ref(space).optional())
    .seq(string('%}'))
    .map((List tokens) {
      String openType = tokens[2];
      String closeType = tokens[14];
      if (openType != closeType) {
        throw 'Closing fragment {% /${closeType} %} does not match '
          'opening fragment {% ${openType} %}.';
      }
      final fragment = new Fragment()
        ..type = openType
        ..inputExpression = tokens[5]
        ..childNodes.addAll(tokens[10]);
      if (tokens[6] is List) {
        fragment.outVars.addAll(tokens[6]);
      }
      return fragment;
    });

  plainText() => new PlainTextParser();

  // TODO: differentiate between html and component names:
  //   - component names may contain "$" and other Dart identifier characters
  htmlElementName() => pattern('a-z').seq(ref(htmlIdentifierChar).star())
      .flatten();

  attributeName() => pattern('a-z').seq(ref(htmlIdentifierChar).star())
      .flatten();

  dartVariableName() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  eventType() => pattern('a-z').seq(ref(htmlIdentifierChar).star())
      .flatten();

  dartClassName() => pattern('A-Z').seq(ref(identifierNameChar).star())
      .flatten();

  identifierNameChar() => pattern('a-zA-Z0-9');  // TODO: accept more

  htmlIdentifierChar() => pattern('a-zA-Z0-9\\-');  // TODO: accept more

  separator(String separatorChar) => () =>
    ref(space).optional()
    .seq(char(separatorChar))
    .seq(ref(space).optional());

  plainTextCharacter() => predicate(1, (input) => input != '<' && input != '{',
      'illegal plain text character');

  space() => whitespace().plus();
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
        return context.success(new PlainText()..text = buf.toString(), currPos);
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
        if (nextChar == '{' || nextChar == '%' || nextChar == '#') {
          // Bumped into text interpolation, fragment or decorator
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

class AttributeValueParser extends Parser {
  final String quote;

  AttributeValueParser(this.quote);

  @override
  Result parseOn(Context context) {
    final buf = new StringBuffer();
    int currPos = context.position;

    while (currPos < context.buffer.length) {
      final currChar = context.buffer[currPos];
      if (currChar == quote) {
        return context.success(buf.toString(), currPos);
      }
      buf.write(currChar);
      currPos++;
    }
    return context.failure('unexpected end of attribute value', currPos);
  }

  @override
  Parser copy() => this;  // it's stateless

  @override
  String toString() => 'AttributeValueParser';
}

// TODO: build proper expression grammar for extensibility and correctness
Expression _parseExpression(String expressionString) {
  final terms = expressionString.split('.');
  final isThis = (terms.first == 'this');
  final expr = new Expression()
    ..isThis = isThis
    ..terms.addAll(isThis ? terms.skip(1) : terms);
  return expr;
}
