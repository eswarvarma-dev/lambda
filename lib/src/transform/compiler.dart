library lambda.compiler;

import 'parser.dart';

part 'binder.dart';
part 'field_generator_visitor.dart';
part 'build_method_visitor.dart';
part 'update_method_visitor.dart';
part 'template_visitors.dart';
part 'fragment_visitors.dart';

/// Turns a Lambda template to Dart code.
class TemplateCompiler {
  final String _controllerClassName;
  final String _source;
  final _buf = new StringBuffer();
  String _viewClassName;

  TemplateCompiler(this._controllerClassName, this._source) {
    _viewClassName = '${_controllerClassName}\$View';
  }

  String compile() {
    final binder = new TemplateBinder();
    final fieldGenerator = new TemplateFieldGeneratorVisitor();
    final buildMethod =
        new TemplateBuildMethodVisitor(_controllerClassName);
    final updateMethod = new TemplateUpdateMethodVisitor();
    final template = parse(_source);
    template
      ..accept(binder)
      ..accept(fieldGenerator)
      ..accept(buildMethod)
      ..accept(updateMethod);

    _emitViewHeader();
    _emit(fieldGenerator.code);
    _emit(buildMethod.code);
    _emit(updateMethod.code);
    _emitViewFooter();

    for (int i = 0; i < binder.fragments.length; i++) {
      final fragment = binder.fragments[i];
      final fragmentClassName = '${_viewClassName}\$Fragment\$${i}';
      final fc = new FragmentCompiler(_controllerClassName, fragmentClassName,
          fragment);
      _emit(fc.compile());
    };

    return _buf.toString();
  }

  void _emit(Object o) {
    _buf.write(o);
  }

  void _emitViewHeader() {
    _emit(' class ${_viewClassName}'
        ' extends ViewNodeBuilder<${_controllerClassName}> {');
  }

  void _emitViewFooter() {
    _emit('}');
  }
}

class FragmentCompiler {
  final String _controllerClassName;
  final String _fragmentClassName;
  final Fragment _fragment;
  final _buf = new StringBuffer();

  FragmentCompiler(this._controllerClassName, this._fragmentClassName,
      this._fragment);

  String compile() {
    final binder = new FragmentBinder();
    final fieldGenerator = new FragmentFieldGeneratorVisitor();
    final buildMethod = new FragmentBuildMethodVisitor();
    final updateMethod = new FragmentUpdateMethodVisitor();
    _fragment
      ..accept(binder)
      ..accept(fieldGenerator)
      ..accept(buildMethod)
      ..accept(updateMethod);

    _emitFragmentHeader();
    _emit(fieldGenerator.code);
    _emit(buildMethod.code);
    _emit(updateMethod.code);
    _emitFragmentFooter();

    for (int i = 0; i < binder.fragments.length; i++) {
      final fragment = binder.fragments[i];
      final fragmentClassName = '${_fragmentClassName}\$Fragment\$${i}';
      final fc = new FragmentCompiler(_controllerClassName, fragmentClassName,
          fragment);
      _emit(fc.compile());
    };

    return _buf.toString();
  }

  void _emit(Object o) {
    _buf.write(o);
  }

  void _emitFragmentHeader() {
    _emit(' class ${_fragmentClassName}');
    _emit(' extends ViewNodeBuilder<${_controllerClassName}> {');
  }

  void _emitFragmentFooter() {
    _emit('}');
  }
}
