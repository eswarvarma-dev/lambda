part of lambda.browser.node_type;

final COMMENT_TYPE = new CommentNodeType();

class CommentNodeType extends NodeType<Comment> {

  @override
  String toXml(Comment c) => c.value;

  @override
  void applyPatch(dom.Node target, Patch patch) {
    throw new StateError('Comment nodes are not patched. Only replaced.');
  }

  @override
  dom.Comment createNativeNode(Comment comment) {
    return new dom.Comment(comment.value);
  }
}
