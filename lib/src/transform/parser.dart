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

  componentElement() => element(ref(dartClassName), (String name) {
    return new ComponentElement()
      ..type = name;
  });

  attribute() => ref(attributeName)
      .seq(ref(space).optional())
      .seq(char('='))
      .seq(ref(space).optional())
      .seq(ref(attributeValue))
      .map((List tokens) {
        return new Attribute(tokens[0], tokens[4]);
      });
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
    .seq(ref(property))
    .seq(char(']'))
    .seq(ref(space).optional())
    .seq(char('='))
    .seq(ref(space).optional())
    .seq(ref(attributeValue))
    .map((List tokens) {
      return new Prop()
        ..property = tokens[1]
        ..expression = tokens[6];
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
      String name = tokens[1];
      List<DataNode> dataNodes = tokens[2];
      Element elem = astNodeFactory(name);
      elem.attributesAndProps.addAll(dataNodes);
      if (tokens[4] is List) {
        elem.childNodes.addAll(tokens[4][1]);
      }
      return elem;
    });

  fragment() =>
    string('<%')                 // 0
    .seq(ref(space).optional())  // 1
    .seq(ref(dartClassName))     // 2
    .seq(ref(space).optional())  // 3
    .seq(char('('))              // 4
    .seq(ref(expression))        // 5
    // TODO: parse out vars: -> a, b, c
    .seq(char(')'))              // 6
    .seq(ref(space).optional())  // 7
    .seq(string('%>'))           // 8
    .seq(ref(content))           // 9
    .seq(string('<%'))           // 10
    .seq(ref(space).optional())  // 11
    .seq(char('/'))              // 12
    .seq(ref(dartClassName))   // 13
    .seq(ref(space).optional())  // 14
    .seq(string('%>'))           // 15
    .map((List tokens) {
      String openType = tokens[2];
      String closeType = tokens[13];
      if (openType != closeType) {
        throw 'Closing fragment <% /${closeType} %> does not match '
          'opening fragment <% ${openType} %>.';
      }
      final fragment = new Fragment()
        ..type = openType
        ..inExpressions.add(tokens[5])
        ..childNodes.addAll(tokens[9]);
      return fragment;
    });

  // TODO: differentiate between html and component names:
  //   - html tag names may contain "-"
  //   - component names may contain "$" and other Dart identifier characters
  htmlElementName() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  attributeName() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  property() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  eventType() => pattern('a-z').seq(ref(identifierNameChar).star())
      .flatten();

  dartClassName() => pattern('A-Z').seq(ref(identifierNameChar).star())
      .flatten();

  identifierNameChar() => pattern('a-zA-Z');  // TODO: accept more

  plainText() => new PlainTextParser();

  plainTextCharacter() =>
      predicate(1, (input) => input != '<', 'illegal plain text character');

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
