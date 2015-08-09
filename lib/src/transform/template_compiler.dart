part of lambda.transformer;

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _componentClassName;
  final String _template;
  final _buf = new StringBuffer();

  Node _templateRoot;
  final _bindings = <Binding>[];

  TemplateCompiler(this._componentClassName, this._template);

  String compile() {
    _parseTemplate();
    _emitComponentHeader();
    _emit(' return');
    _virtualizeNode(_templateRoot);
    _emit(' ;');
    _emitComponentFooter();
    return _buf.toString();
  }

  String compileBuildBodyForTesting() {
    _parseTemplate();
    _virtualizeNode(_templateRoot);
    return _buf.toString();
  }

  void _virtualizeNode(Node node) {
    if (node is Element) {
      Element elem = node;
      _emit(" vElement('${elem.localName}'");
      if (elem.attributes.isNotEmpty) {
        _emit(' , customAttrs: {');
        elem.attributes.forEach((String attrName, String attrValue) {
          _emit(" '''${attrName}''': '''${attrValue}'''");
        });
        _emit(' }');
      }
      _emit(' )');
      if (elem.hasChildNodes()) {
        _emit(' (');
        _virtualizeNode(elem.nodes.first);
        elem.nodes.skip(1).forEach((Node n) {
          _emit(' ,');
          _virtualizeNode(n);
        });
        _emit(' )');
      }
    } else if (node is Text) {
      int textBindingIndex = -1;
      int currentIndex = 0;
      final value = new StringBuffer();
      while((textBindingIndex = node.text.indexOf('{{', textBindingIndex + 1)) >= 0) {
        int indexOfClosingParens = node.text.indexOf('}}', textBindingIndex + 1);
        int bindingIndex = int.parse(node.text.substring(textBindingIndex + 2, indexOfClosingParens));
        value
            ..write(node.text.substring(currentIndex, textBindingIndex))
            ..write('\${context.')
            ..write((_bindings[bindingIndex] as TextBinding).expression)
            ..write('}');
        currentIndex = indexOfClosingParens + 2;
      }
      value.write(node.text.substring(currentIndex));
      _emit(" vText('''${value}''')");
    } else {
      throw 'Node type ${node.runtimeType} not yet supported.';
    }
  }

  static final RegExp textBindings = new RegExp(r'\{\{[^(}})]*\}\}');

  void _parseTemplate() {
    final clean = new StringBuffer();
    int currentIndex = 0;
    textBindings.allMatches(_template).forEach((Match m) {
      String expression = _template.substring(m.start + 2, m.end - 2);
      _bindings.add(new TextBinding(expression));
      clean
        ..write(_template.substring(currentIndex, m.start))
        ..write('{{${_bindings.length - 1}}}');
      currentIndex = m.end;
    });
    clean.write(_template.substring(currentIndex));
    _templateRoot = new HtmlParser(clean.toString()).parseFragment().children.single;
  }

  void _emitComponentHeader() {
    _emit(
      ' class ${_componentClassName}\$Component'
      ' extends LambdaComponent<Button> {'
      ' @override'
      ' build() {'
    );
  }

  void _emitComponentFooter() {
    _emit('} }');
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}

abstract class Binding {}

class TextBinding implements Binding {
  final String expression;
  TextBinding(this.expression);
}
