library lambda.compiler;

import 'dart:async';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/java_core.dart';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as path;

class LambdaTransformer extends Transformer {

  LambdaTransformer.asPlugin();

  static const _EXTENSION = '.ui.dart';

  @override
  bool isPrimary(AssetId id) => id.path.endsWith(_EXTENSION);

  @override
  Future apply(Transform transform) async {
    final code = await transform.primaryInput.readAsString();
    final ast = parseCompilationUnit(code, parseFunctionBodies: true);
    final asset = transform.primaryInput;
    final directory = path.dirname(asset.id.path);
    // call basenameWithoutExtension because we use double-extension
    final baseName = path.basenameWithoutExtension(
      path.basenameWithoutExtension(asset.id.path));
    final genFileName = '${baseName}.gen.dart';
    final visitor = new _RewriterVisitor(genFileName);
    ast.accept(visitor);
    String genPath = transform.primaryInput.id.path;
    genPath = path.join(directory, genFileName);
    final genAssetId = new AssetId(transform.primaryInput.id.package, genPath);
    transform.addOutput(new Asset.fromString(genAssetId, visitor.genCode));
    transform.addOutput(
      new Asset.fromString(transform.primaryInput.id, visitor.uiCode));
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

  _RewriterVisitor._private(this._genFileName, PrintStringWriter pw)
      : super(pw), _uiCode = pw;

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
    Annotation viewAnnotation = node.metadata
      .firstWhere((Annotation ann) => ann.name.name == 'View',
          orElse: () => null);
    final componentClassName = node.name.name;
    if (viewAnnotation != null) {
      var template = viewAnnotation.arguments.arguments.single
          .accept(_evaluator);
      if (template is String) {
        _genCode.writeln('''
class ${componentClassName}\$Component extends LambdaComponent<Button> {
  @override
  build() {
    return vElement('div');
  }
}
''');
      } else {
        print('WARNING: @View template is not a String: $template');
      }
    }
    return super.visitClassDeclaration(node);
  }
}
