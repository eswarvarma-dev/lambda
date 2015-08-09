part of lambda.transformer;

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _componentClassName;
  final String _template;
  final _buf = new StringBuffer();

  XmlNode _templateRoot;
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

  void _virtualizeNode(XmlNode node) {
    if (node is XmlElement) {
      _virtualizeElement(node);
    } else if (node is XmlText) {
      _virtualizeText(node);
    } else {
      throw 'Node type ${node.runtimeType} not yet supported.';
    }
  }

  void _virtualizeElement(XmlElement elem) {
    _emit(" vElement('${elem.name.local}'");
    if (elem.attributes.isNotEmpty) {
      _emit(' , customAttrs: {');
      elem.attributes.forEach((XmlAttribute attr) {
        _emit(" '''${attr.name.local}''': '''${attr.value}'''");
      });
      _emit(' }');
    }
    _emit(' )');
    if (elem.children.isNotEmpty) {
      _emit(' (');
      _virtualizeNode(elem.children.first);
      elem.children.skip(1).forEach((XmlNode n) {
        _emit(' ,');
        _virtualizeNode(n);
      });
      _emit(' )');
    }
  }

  void _virtualizeText(XmlText node) {
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
    _templateRoot = parse(clean.toString()).rootElement;
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
