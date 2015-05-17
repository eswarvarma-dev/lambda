part of lambda.browser.node_type;

final TEXT_TYPE = new TextNodeType();

class TextNodeType extends NodeType<Text> {

  @override
  String toXml(Text t) => t.value;

  @override
  void applyPatch(dom.Node target, Patch patch) {
    throw new StateError('Text nodes are not patched. Only replaced.');
  }

  @override
  dom.Text createNativeNode(Text node) {
    return new dom.Text(node.value);
  }
}
