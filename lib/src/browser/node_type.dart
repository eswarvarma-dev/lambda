library lambda.browser.node_type;

import 'dart:html' as dom;
import 'package:lambda/lambda.dart';

part 'node_type/comment_type.dart';
part 'node_type/element_type.dart';
part 'node_type/projection_type.dart';
part 'node_type/text_type.dart';

final _nodeTypeRegistry = <NodeType>[];

abstract class NodeType<T extends Node> {

  static NodeType forNode(Node node) {
    return _nodeTypeRegistry[node.typeIndex];
  }

  static NodeType forPatch(Patch patch) {
    return _nodeTypeRegistry[patch.nodeTypeIndex];
  }

  static NodeType forTypeIndex(int nodeTypeIndex) {
    return _nodeTypeRegistry[nodeTypeIndex];
  }

  final int typeIndex;

  NodeType() : this.typeIndex = _nodeTypeRegistry.length {
    _nodeTypeRegistry.add(this);
    assert(identical(this, _nodeTypeRegistry[this.typeIndex]));
  }

  void applyPatch(dom.Node target, Patch patch);

  dom.Node createNativeNode(Node node);

  String toXml(T node);
}
