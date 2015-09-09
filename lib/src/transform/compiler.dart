library lambda.compiler;

import 'parser.dart';

part 'binder.dart';
part 'field_generator_visitor.dart';
part 'build_method_visitor.dart';
part 'update_method_visitor.dart';
part 'template_visitors.dart';

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _controllerClassName;
  final String _source;
  final _buf = new StringBuffer();

  TemplateCompiler(this._controllerClassName, this._source);

  String compile() {
    final binder = new TemplateBinder();
    final fieldGeneratorVisitor = new TemplateFieldGeneratorVisitor();
    final buildMethodVisitor =
        new TemplateBuildMethodVisitor(_controllerClassName);
    final updateMethodVisitor = new TemplateUpdateMethodVisitor();
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
