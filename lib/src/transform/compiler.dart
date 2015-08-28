part of lambda.compiler;

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _controllerClassName;
  final String _template;
  final _buf = new StringBuffer();
  final _bindings = <Binding>[];
  final _elements = <XmlElement, int>{};

  int _elementCounter = 0;
  XmlNode _templateRoot;

  TemplateCompiler(this._controllerClassName, this._template);

  String compile() {
    _parseTemplate();

    _emitViewHeader();

    _emitBuildHeader();
    _virtualizeNode(_templateRoot);
    _emitBuildFooter();

    _emitUpdateMethod();

    _emitViewFooter();
    return _buf.toString();
  }

  String compileVirtualTreeForTesting_() {
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
    _elements[elem] = _elementCounter++;
    final elemName = elem.name.local;

    if (elemName[0] == elemName[0].toLowerCase()) {
      _emit(" beginElement('${elemName}'");
    } else {
      _emit(" beginChild(${elemName}.viewFactory()");
    }
    if (elem.attributes.isNotEmpty) {
      _emit(' , attrs: const {');
      elem.attributes.forEach((XmlAttribute attr) {
        _emit(" '''${attr.name.local}''': '''${attr.value}'''");
      });
      _emit(' }');
    }
    _emit(' );');

    elem.children.forEach((XmlNode n) {
      _virtualizeNode(n);
    });

    _emit(' endElement();');
  }

  void _virtualizeText(XmlText node) {
    int textBindingIndex = -1;
    int currentIndex = 0;
    final value = new StringBuffer();
    while ((textBindingIndex = node.text.indexOf('{{', textBindingIndex + 1)) >=
        0) {
      int indexOfClosingParens = node.text.indexOf('}}', textBindingIndex + 1);
      int bindingIndex = int.parse(
          node.text.substring(textBindingIndex + 2, indexOfClosingParens));
      value
        ..write(node.text.substring(currentIndex, textBindingIndex))
        ..write('\${context.')
        ..write((_bindings[bindingIndex] as TextBinding).expression)
        ..write('}');
      currentIndex = indexOfClosingParens + 2;
    }
    value.write(node.text.substring(currentIndex));
    _emit(" addText('''${value}''');");
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

  void _emitViewHeader() {
    _emit(' class ${_controllerClassName}\$View'
        ' extends ViewObjectBuilder<Button> {');
  }

  void _emitBuildHeader() {
    _emit(' @override'
        ' build() {'
        ' final context = new ${_controllerClassName}();'
        ' beginHost(\'${_controllerClassName}\');');
  }

  void _emitBuildFooter() {
    _emit(' endHost(); }');
  }

  void _emitUpdateMethod() {
    _emit(' @override update() {');
    _emit(' }');
  }

  void _emitViewFooter() {
    _emit('}');
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
