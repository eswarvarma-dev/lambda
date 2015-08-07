library lambda.compiler;

import 'dart:async';
import 'package:barback/barback.dart';

class LambdaCompiler extends Transformer {

  LambdaCompiler();

  @override
  bool isPrimary(AssetId id) => id.path.endsWith('.ui.dart');

  @override
  Future apply(Transform transform) async {

  }

}
