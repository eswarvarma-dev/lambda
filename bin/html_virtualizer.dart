import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

String url;

main(List<String> args) async {
  parseArgs(args);

  var uri = Uri.parse(url);
  var client = new HttpClient();
  var resp = await (await client.getUrl(uri)).close();
  var data = (await(resp
      .transform(const Utf8Decoder())
      .fold(new StringBuffer(), (buf, e) => buf..write(e))))
          .toString();
  client.close();

  var dom = parse(data);
  var elementTypes = new Set();
  var code = virtualize(dom.children.first, '  ', elementTypes);

  print('''
library ${uri.host};

import 'package:lambda/lambda.dart';

${elementTypes.map((t) => 'final ${t}_type = new ElementNodeType("$t");').join('\n')}

Element lotsOfHtml() {
  return ${code};
}
''');
}

String virtualize(Node node, String indent, Set nodeNames) {
  if (node is Element) {
    Element el = node;
    nodeNames.add(node.localName);
    var attrs = new StringBuffer('{');
    el.attributes.forEach((attrName, attrValue) {
      attrs.write('"${attrName}":"${attrValue}",');
    });
    attrs.write('}');
    var virtualizedChildren = node.nodes
        .map((n) => virtualize(n, '$indent  ', nodeNames));
    return
      '${indent}new Element(${node.localName}_type, children: [\n'
      '${virtualizedChildren.join(',\n')}'
      '\n${indent}], attributes: ${attrs.toString()})';
  } else if (node is Text) {
    return '${indent}new Text("""${_dartEscape(node.text)}""")';
  } else if (node is Comment) {
    return '${indent}new Comment("""${_dartEscape(node.text)}""")';
  }
  throw node.runtimeType;
}

String _dartEscape(String s) {
  return s
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll(r'"', r'\"')
    .replaceAll(r"'", r"\'");
}

void parseArgs(List<String> args) {
  var argp = new ArgParser();

  argp.addOption(
    'url',
    abbr: 'u',
    callback: (String value) {
      url = value;
    }
  );

  argp.parse(args);
}
