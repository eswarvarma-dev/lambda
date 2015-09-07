library lambda.compiler;

import 'parser.dart';

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _controllerClassName;
  final String _source;
  final _buf = new StringBuffer();

  TemplateCompiler(this._controllerClassName, this._source);

  String compile() {
    final binder = new Binder();
    final fieldGeneratorVisitor = new FieldGeneratorVisitor();
    final buildMethodVisitor = new BuildMethodVisitor(_controllerClassName);
    final updateMethodVisitor = new UpdateMethodVisitor();
    final template = parse(_source);
    template
      ..accept(binder)
      ..accept(fieldGeneratorVisitor)
      ..accept(buildMethodVisitor)
      ..accept(updateMethodVisitor);

    _emitViewHeader();
    _emit(fieldGeneratorVisitor.code);
    _emit(buildMethodVisitor.code);
    _emit(updateMethodVisitor.code);
    _emitViewFooter();

    return _buf.toString();
  }

  void _emit(Object o) {
    _buf.write(o);
  }

  void _emitViewHeader() {
    _emit(' class ${_controllerClassName}\$View'
        ' extends ViewNodeBuilder<${_controllerClassName}> {');
  }

  void _emitViewFooter() {
    _emit('}');
  }
}

/// Enriches the AST with binding code information, such as field names.
class Binder extends AstVisitor {

  int _idx = 0;

  @override
  bool visitHtmlElement(HtmlElement elem) {
    elem
      ..isBound = elem.attributesAndProps.any((DataNode node) => node is Prop)
      ..nodeField = '_element${_idx++}';
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    elem.nodeField = '_child${_idx++}';
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    txti.nodeField = '_textInterpolationNode${_idx}';
    txti.valueField = '_textInterpolationValue${_idx}';
    _idx++;
    return false;
  }

  @override
  bool visitProp(Prop p) {
    p.valueField = '_prop${_idx++}';
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    f.fragmentField = '_fragment${_idx++}';
    return true;
  }
}

/// Generates bound fields.
class FieldGeneratorVisitor extends AstVisitor {
  final _buf = new StringBuffer();

  String get code => _buf.toString();

  @override
  bool visitHtmlElement(HtmlElement elem) {
    // Create fields only for bound nodes
    if (elem.isBound) {
      _emit(' Element ${elem.nodeField};');
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    _emit(' ${elem.type} ${elem.nodeField};');
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    _emit(' Text ${txti.nodeField};');
    _emit(' String ${txti.valueField};');
    return false;
  }

  @override
  bool visitProp(Prop p) {
    _emit(' var ${p.valueField};');
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    _emit(' var ${f.fragmentField};');
    return true;
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}

/// Generates code for the `build` method.
class BuildMethodVisitor extends AstVisitor {
  final String _controllerClassName;
  final String _hostElementName;
  final _buf = new StringBuffer();

  BuildMethodVisitor(controllerClassName)
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

/// Generates code for the `update` method.
class UpdateMethodVisitor extends AstVisitor {
  final _buf = new StringBuffer();

  String get code => _buf.toString();

  @override
  bool visitTemplate(Template template) {
    _emit(' @override\n');
    _emit(' void update() {');
    _emit('   var _tmp;');
    return false;
  }

  @override
  void didVisitNode(AstNode node) {
    if (node is Template) {
      _emit(' }');
    }
  }

  @override
  bool visitHtmlElement(HtmlElement elem) {
    if (elem.isBound) {
      _emitPropChangeDetection(elem);
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    _emitPropChangeDetection(elem);
    return false;
  }

  void _emitPropChangeDetection(Element elem) {
    elem.attributesAndProps
      .where((n) => n is Prop)
      .forEach((Prop p) {
        _emit(' _tmp = context.${p.expression};');
        _emit(' if (!identical(_tmp, ${elem.nodeField})) {');
        _emit('   ${elem.nodeField}.${p.property} = ${p.valueField} = _tmp;');
        _emit(' }');
      });
  }

  @override
  bool visitTextInterpolation(TextInterpolation ti) {
    _emit(' _tmp = \'\${context.${ti.expression}}\';');
    _emit(' if (!identical(_tmp, ${ti.valueField})) {');
    _emit('   ${ti.nodeField}.text = ${ti.valueField} = _tmp;');
    _emit(' }');
    return false;
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}

String snakeCase(String s) {
  final buf = new StringBuffer(s[0].toLowerCase());
  for (int i = 1; i < s.length; i++) {
    var lowerCaseChar = s[i].toLowerCase();
    if (lowerCaseChar != s[i]) {
      buf.write('-');
    }
    buf.write(lowerCaseChar);
  }
  return buf.toString();
}
