library lambda.transform.app_model;

import 'package:analyzer/analyzer.dart';

class UiFile {
  List<UiComponent> _components;
}

class UiComponent {
  String template;
}

UiFile parseUiFile(String filePath, String code) {
  var ast = parseCompilationUnit(code, name: filePath,
      parseFunctionBodies: false);
}

class _UiFileParser extends Object with RecursiveAstVisitor<Object> {

}
