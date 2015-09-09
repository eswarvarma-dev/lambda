part of lambda.compiler;

/// Generates code for the `build` method.
abstract class BaseBuildMethodVisitor extends AstVisitor {
  final String _controllerClassName;
  final String _hostElementName;
  final _buf = new StringBuffer();

  BaseBuildMethodVisitor(controllerClassName)
    : _controllerClassName = controllerClassName,
      _hostElementName = snakeCase(controllerClassName);

  String get code => _buf.toString();

  @override
  bool visitTemplate(Template template) {
    _emit(' @override\n'
        ' build() {'
        '   this.context = new ${_controllerClassName}();'
        '   beginHost(\'${_hostElementName}\');');
    return false;
  }

  @override
  bool visitHtmlElement(HtmlElement elem) {
    final tag = elem.tag;
    bool hasEvents = elem.attributesAndProps.any((p) => p is Event);
    if (elem.isBound) {
      _emit(' ${elem.nodeField} = ');
    }
    // If we're listening to events on this element, store the element reference
    // in a local variable in order to create subscriptions.
    else if (hasEvents) {
      _emit(' Element ${elem.nodeField} = ');
    }
    _emit(" beginElement('${tag}'");
    _emitAttributes(elem);
    _emit(' );');
    if (hasEvents) {
      elem.attributesAndProps.where((n) => n is Event).forEach((Event e) {
        _emitSubscription(elem.nodeField, e);
      });
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    final tag = elem.type;
    _emit(' ${elem.nodeField} = beginChild(${tag}.viewFactory()');
    _emitAttributes(elem);
    _emit(' );');
    bool hasEvents = elem.attributesAndProps.any((p) => p is Event);
    if (hasEvents) {
      elem.attributesAndProps.where((n) => n is Event).forEach((Event e) {
        _emitSubscription(elem.nodeField, e);
      });
    }
    return false;
  }

  _emitSubscription(String nodeVariable, Event event) {
    _emit(' subscribe(');
    _emit('   ${nodeVariable}.on[\'${event.type}\'],');
    _emit('   context.${event.statement}');
    _emit(' );');
  }

  @override
  bool visitPlainText(PlainText ptxt) {
    _emit(" addText('''${ptxt.text}''');");
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    _emit(' ${txti.nodeField} = addTextInterpolation();');
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    _emit(' addFragmentPlaceholder(${f.fragmentField} = new ${f.type}());');
    return true;
  }

  void _emitAttributes(Element elem) {
    var attrs = elem.attributesAndProps.where((n) => n is Attribute);
    if (attrs.isNotEmpty) {
      _emit(' , attrs: const {');
      attrs.forEach((Attribute attr) {
        _emit(" '''${attr.name}''': '''${attr.value}'''");
      });
      _emit(' }');
    }
  }

  @override
  void didVisitNode(AstNode node) {
    if (node is Template) {
      _emitBuildFooter();
    } else if (node is Element) {
      _emit(' endElement();');
    }
  }

  void _emitBuildFooter() {
    _emit(' endHost(); }');
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}
