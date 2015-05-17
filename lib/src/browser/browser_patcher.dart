library lambda.browser_syncer;

import 'dart:html' as dom;
import 'package:lambda/lambda.dart';
import 'node_type.dart';

class BrowserPatcher {
  final dom.Element _host;

  BrowserPatcher.adopt(this._host);

  void apply(Patch patch) {
    NodeType.forPatch(patch).applyPatch(_host, patch);
  }
}
