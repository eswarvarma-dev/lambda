part of lambda.transformer;

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _componentClassName;
  final String _template;
  final _buf = new StringBuffer();

  Node _templateRoot;

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
        elem.nodes.forEach(_virtualizeNode);
        _emit(' )');
      }
    } else if (node is Text) {
      _emit(" vText('''${node.text}''')");
    } else {
      throw 'Node type ${node.runtimeType} not yet supported.';
    }
  }

  void _parseTemplate() {
    _templateRoot = new HtmlParser(_template).parseFragment().children.single;
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
