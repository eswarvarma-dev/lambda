part of lambda.compiler;

class TemplateBinder extends BaseBinder {
  TemplateBinder(String viewClassName) : super(viewClassName);
}

class TemplateFieldGeneratorVisitor extends BaseFieldGeneratorVisitor {}

class TemplateBuildMethodVisitor extends BaseBuildMethodVisitor {
  final String _controllerClassName;
  final String _hostElementName;

  TemplateBuildMethodVisitor(controllerClassName)
    : _controllerClassName = controllerClassName,
      _hostElementName = snakeCase(controllerClassName);

  @override
  bool visitTemplate(Template template) {
    _emit(' @override\n');
    _emit(' build() {');
    _emit('   beginHost(\'${_hostElementName}\', new ${_controllerClassName}());');
    return false;
  }

  @override
  void didVisitNode(AstNode node) {
    super.didVisitNode(node);
    if (node is Template) {
      _emitBuildFooter();
    }
  }

  void _emitBuildFooter() {
    _emit(' endBuild(); }');
  }
}

class TemplateUpdateMethodVisitor extends BaseUpdateMethodVisitor {

  @override
  Fragment get currentFragment => null;

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
}
