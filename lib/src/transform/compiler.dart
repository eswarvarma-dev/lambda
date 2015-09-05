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
  void visitHtmlElement(HtmlElement elem) {
    if(elem.attributesAndProps.any((DataNode node) => node is Prop)) {
      // This element has property bindings on it and therefore needs to be
      // stored in a field
      elem
        ..isBound = true
        ..field = '_boundElement${_idx++}';
    }
  }

  @override
  void visitComponentElement(ComponentElement elem) {
    elem.field = '_child${_idx++}';
  }

  @override
  void visitTextInterpolation(TextInterpolation txti) {
    txti.nodeField = '_textInterpolationNode${_idx}';
    txti.valueField = '_textInterpolationValue${_idx}';
    _idx++;
  }
}

/// Generates bound fields.
class FieldGeneratorVisitor extends AstVisitor {
  final _buf = new StringBuffer();

  String get code => _buf.toString();

  @override
  void visitHtmlElement(HtmlElement elem) {
    if (elem.isBound) {
      _emit(' Element ${elem.field};');
    }
  }

  @override
  void visitComponentElement(ComponentElement elem) {
    _emit(' ${elem.type} ${elem.field};');
  }

  @override
  void visitTextInterpolation(TextInterpolation txti) {
    _emit(" Text ${txti.nodeField};");
    _emit(" String ${txti.valueField};");
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}

/// Generates code for the `build` method.
class BuildMethodVisitor extends AstVisitor {
  final String _controllerClassName;
  final _buf = new StringBuffer();

  BuildMethodVisitor(this._controllerClassName);

  String get code => _buf.toString();

  @override
  void visitTemplate(Template template) {
    _emit(' @override\n'
        ' build() {'
        '   this.context = new ${_controllerClassName}();'
        '   beginHost(\'${_controllerClassName}\');');
  }

  @override
  void visitHtmlElement(HtmlElement elem) {
    final tag = elem.tag;
    if (elem.isBound) {
      _emit(' ${elem.field} = ');
    }
    _emit(" beginElement('${tag}'");
    _emitAttributes(elem);
    _emit(' );');
  }

  @override
  void visitComponentElement(ComponentElement elem) {
    final tag = elem.type;
    _emit(' ${elem.field} = beginChild(${tag}.viewFactory()');
    _emitAttributes(elem);
    _emit(' );');
  }

  @override
  void visitPlainText(PlainText ptxt) {
    _emit(" addText('''${ptxt.text}''');");
  }

  @override
  void visitTextInterpolation(TextInterpolation txti) {
    _emit(" ${txti.nodeField} = addTextInterpolation();");
  }

  void _emitAttributes(Element elem) {
    if (elem.attributesAndProps.isNotEmpty) {
      _emit(' , attrs: const {');
      elem.attributesAndProps
        .where((n) => n is Attribute)
        .forEach((Attribute attr) {
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
  void visitTemplate(Template template) {
    _emit(' @override\n');
    _emit(' void update() {');
    _emit('   var _tmp;');
  }

  @override
  void didVisitNode(AstNode node) {
    if (node is Template) {
      _emit(' }');
    }
  }

  @override
  void visitHtmlElement(HtmlElement elem) {
    if (elem.isBound) {
      _emitPropChangeDetection(elem);
    }
  }

  @override
  void visitComponentElement(ComponentElement elem) {
    _emitPropChangeDetection(elem);
  }

  void _emitPropChangeDetection(Element elem) {
    elem.attributesAndProps
      .where((n) => n is Prop)
      .forEach((Prop p) {
        _emit(' _tmp = context.${p.expression};');
        _emit(' if (!identical(_tmp, ${elem.field})) {');
        _emit('   ${elem.field}.${p.property} = ${elem.field} = _tmp;');
        _emit(' }');
      });
  }

  @override
  void visitTextInterpolation(TextInterpolation ti) {
    _emit(' _tmp = \'\${context.${ti.expression}}\';');
    _emit(' if (!identical(_tmp, ${ti.valueField})) {');
    _emit('   ${ti.nodeField}.text = ${ti.valueField} = _tmp;');
    _emit(' }');
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}
