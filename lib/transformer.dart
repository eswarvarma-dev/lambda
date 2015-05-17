library lambda.compiler;

import 'package:barback/barback.dart';

class Compiler extends Transformer {

  Compiler();

  @override
  bool isPrimary(AssetId id) => id.path.endsWith('.ui.dart');

  @override
  Future apply(Transform transform) async {

  }

}
