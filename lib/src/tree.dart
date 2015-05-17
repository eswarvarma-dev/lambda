/**
 * Implementation of immutable virtual tree.
 */
library lambda.tree;

import 'dart:math';

part 'tree/comment.dart';
part 'tree/element.dart';
part 'tree/projection.dart';
part 'tree/text.dart';

final _NO_CHILDREN = const <Node>[];
final _NO_ATTRS = const <String, String>{};

abstract class Node {
  final int typeIndex;

  Node(this.typeIndex);

  /// Creates a [Patch] that, when applied to [other], produces a node tree
  /// identical with `this` node tree.
  ///
  /// Usually [other] is the previous tree state in a series of tree
  /// transformations.
  Patch diff(int selfIndex, Node other);
}

abstract class Patch {
  /// Which type of node is being patched
  final int nodeTypeIndex;
  /// Index on the patched node in the parent
  final int index;

  Patch(this.nodeTypeIndex, this.index);
}

class ReplacementPatch extends Patch {
  final Node replacement;
  ReplacementPatch(int index, Node replacement)
      : super(replacement.typeIndex, index),
        this.replacement = replacement;
}
