part of lambda.compiler;

class TemplateBinder extends BaseBinder {}

class TemplateFieldGeneratorVisitor extends BaseFieldGeneratorVisitor {}

class TemplateBuildMethodVisitor extends BaseBuildMethodVisitor {
    TemplateBuildMethodVisitor(controllerClassName)
        : super(controllerClassName);
}

class TemplateUpdateMethodVisitor extends BaseUpdateMethodVisitor {}
