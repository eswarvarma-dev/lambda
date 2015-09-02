library lambda.compiler;

import 'parser.dart';

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _controllerClassName;
  final String _source;
  final _buf = new StringBuffer();

  TemplateCompiler(this._controllerClassName, this._source);

  String compile() {
    final buildMethodVisitor = new BuildMethodVisitor(_controllerClassName);
    final updateMethodVisitor = new UpdateMethodVisitor();
    final template = parse(_source);
    template
      ..accept(buildMethodVisitor)
      ..accept(updateMethodVisitor);

    _emitViewHeader();
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
        ' extends ViewNodeBuilder<Button> {');
  }

  void _emitViewFooter() {
    _emit('}');
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
    _emitBuildHeader();
  }

  @override
  void visitHtmlElement(HtmlElement elem) {
    final tag = elem.tag;
    _emit(" beginElement('${tag}'");
    _emitAttributes(elem);
    _emit(' );');
  }

  @override
  void visitComponentElement(ComponentElement elem) {
    final tag = elem.type;
    _emit(' beginChild(${tag}.viewFactory()');
    _emitAttributes(elem);
    _emit(' );');
  }

  @override
  void visitPlainText(PlainText ptxt) {
    _emit(" addText('''${ptxt.text}''');");
  }

  @override
  void visitTextInterpolation(TextInterpolation txti) {
    _emit(" addTextInterpolation();");
  }

  void _emitAttributes(Element elem) {
    if (elem.attributesAndProps.isNotEmpty) {
      _emit(' , attrs: const {');
      elem.attributesAndProps.forEach((Attribute attr) {
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

  void _emitBuildHeader() {
    _emit(' @override\n'
        ' build() {'
        ' final context = new ${_controllerClassName}();'
        ' beginHost(\'${_controllerClassName}\');');
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
}
