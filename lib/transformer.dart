library lambda.transformer;

import 'dart:async';
import 'dart:io';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/java_core.dart';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';
import 'src/transform/compiler.dart';

final _formatter = new DartFormatter();
String _fmt(String code) => _formatter.format(code);

class LambdaTransformer extends Transformer implements DeclaringTransformer {
  LambdaTransformer.asPlugin();

  static const _EXTENSION = '.ui.dart';
  static const _TEST_EXTENSION = '.ui_test.dart';

  @override
  bool isPrimary(AssetId id) {
    return id.path.endsWith(_EXTENSION) || id.path.endsWith(_TEST_EXTENSION);
  }

  @override
  void declareOutputs(DeclaringTransform transform) {
    final info = new UiFileInfo(transform.primaryId);
    transform.declareOutput(info._outputAssetId);
    transform.declareOutput(info._assetId);
  }

  @override
  Future apply(Transform transform) async {
    final info = new UiFileInfo(transform.primaryInput.id);
    try {
      final code = await transform.primaryInput.readAsString();
      final ast = parseCompilationUnit(code, parseFunctionBodies: true);
      final visitor = new _RewriterVisitor(info._genFileName);
      ast.accept(visitor);
      final formattedGenCode = _fmt(visitor.genCode);
      final formattedUiCode = _fmt(visitor.uiCode);
      transform
          .addOutput(new Asset.fromString(info._outputAssetId, formattedGenCode));
      transform.addOutput(new Asset.fromString(info._assetId, formattedUiCode));
    } catch (e, s) {
      stderr.writeln(
        'Failed to transform and therefore skipping ${info._assetId}:\n'
        'ERROR: $e\n'
        'STACK TRACE: $s');
    }
  }
}

class UiFileInfo {
  final AssetId _assetId;
  String _inputDirectory;
  String _baseFileName;
  String _genFileName;
  String _genPath;
  AssetId _outputAssetId;

  UiFileInfo(this._assetId) {
    _inputDirectory = path.dirname(_assetId.path);
    // call basenameWithoutExtension because we use double-extension
    _baseFileName = path
        .basenameWithoutExtension(path.basenameWithoutExtension(_assetId.path));
    _genFileName = '${_baseFileName}.gen.dart';
    _genPath = path.join(_inputDirectory, _genFileName);
    _outputAssetId = new AssetId(_assetId.package, _genPath);
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
        (Annotation ann) => ann.name.name == 'View',
        orElse: () => null);
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
