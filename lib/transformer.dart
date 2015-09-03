library lambda.transformer;

import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/java_core.dart';
import 'package:barback/barback.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';
import 'src/transform/compiler.dart';

final _formatter = new DartFormatter();
String _fmt(String code) => _formatter.format(code);

class LambdaTransformer extends Transformer {
  LambdaTransformer.asPlugin();

  static const _EXTENSION = '.ui.dart';
  static const _TEST_EXTENSION = '.ui_test.dart';

  @override
  bool isPrimary(AssetId id) {
    return id.path.endsWith(_EXTENSION) ||
        id.path.endsWith(_TEST_EXTENSION);
  }

  @override
  Future apply(Transform transform) async {
    final code = await transform.primaryInput.readAsString();
    final ast = parseCompilationUnit(code, parseFunctionBodies: true);
    final asset = transform.primaryInput;
    final directory = path.dirname(asset.id.path);
    // call basenameWithoutExtension because we use double-extension
    final baseName = path
        .basenameWithoutExtension(path.basenameWithoutExtension(asset.id.path));
    final genFileName = '${baseName}.gen.dart';
    final visitor = new _RewriterVisitor(genFileName);
    ast.accept(visitor);
    String genPath = transform.primaryInput.id.path;
    genPath = path.join(directory, genFileName);
    final genAssetId = new AssetId(transform.primaryInput.id.package, genPath);
    final formattedGenCode = _fmt(visitor.genCode);
    final formattedUiCode = _fmt(visitor.uiCode);
    transform.addOutput(new Asset.fromString(genAssetId, formattedGenCode));
    transform.addOutput(
        new Asset.fromString(transform.primaryInput.id, formattedUiCode));
  }
}

/// Simultaneously rewrites `.ui.dart` code _and_ generates `.gen.dart` code.
class _RewriterVisitor extends ToSourceVisitor {
  static final _evaluator = new ConstantEvaluator();

  final String _genFileName;
  /// Contains generated `.gen.dart` code.
  final _genCode = new StringBuffer();
  /// Contains rewritten `.ui.dart` code.
  final PrintStringWriter _uiCode;

  String _viewClassName;

  _RewriterVisitor._private(this._genFileName, PrintStringWriter pw)
      : super(pw),
        _uiCode = pw;

  String get genCode => _genCode.toString();
  String get uiCode => _uiCode.toString();

  factory _RewriterVisitor(String genFileName) {
    final pw = new PrintStringWriter();
    return new _RewriterVisitor._private(genFileName, pw);
  }

  void _writeUiNode(AstNode node) {
    final _writer = new PrintStringWriter();
    node.accept(new ToSourceVisitor(_writer));
    _uiCode.print(_writer.toString());
  }

  @override
  visitLibraryDirective(LibraryDirective node) {
    _genCode.writeln('part of ${node.name.name};');
    _writeUiNode(node);
  }

  @override
  visitAnnotation(Annotation node) {
    if (node.name.name == 'LambdaUi') {
      _uiCode.println("part '${_genFileName}';");
    } else {
      return super.visitAnnotation(node);
    }
  }

  @override
  AstNode visitClassDeclaration(ClassDeclaration node) {
    Annotation viewAnnotation = node.metadata.firstWhere(
        (Annotation ann) => ann.name.name == 'View', orElse: () => null);
    if (viewAnnotation != null) {
      var template =
          viewAnnotation.arguments.arguments.single.accept(_evaluator);
      if (template is String) {
        final componentClassName = node.name.name;
        _viewClassName = '${componentClassName}\$View';
        _genCode.writeln(
            new TemplateCompiler(componentClassName, template).compile());
      } else {
        print('WARNING: @View template is not a String: $template');
      }
    }
    return super.visitClassDeclaration(node);
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    if (node.isStatic && node.name.name == 'viewFactory') {
      assert(_viewClassName != null);
      _uiCode.print(
          'static ${_viewClassName} viewFactory() => new ${_viewClassName}();');
    } else {
      return super.visitMethodDeclaration(node);
    }
  }
}
