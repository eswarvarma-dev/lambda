part of lambda.tree;

class Element extends Node {
  final List<Node> _children;
  final Map<String, String> _attributes;

  Element(int typeIndex, {
    List<Node> children,
    Map<String, String> attributes
  }) : super(typeIndex),
       this._children = children != null
         ? children
         : _NO_CHILDREN,
       this._attributes = attributes != null
         ? attributes
         : _NO_ATTRS;

  List<Node> get children => _children;

  Node operator[](int index) {
    return _children[index];
  }

  int get length => _children.length;

  bool get hasAttributes =>
    _attributes != null &&
    _attributes.isNotEmpty;

  Map<String, String> get attributes {
    return _attributes;
  }

  bool get hasChildren =>
    _children != null &&
    _children.isNotEmpty;

  Element queryById(String id) {
    if (this.attributes['id'] == id) {
      return this;
    } else if (hasChildren) {
      for (int i = 0; i < _children.length; i++) {
        if (_children[i] is! Element) continue;
        Element childElem = _children[i];
        Element childResult = childElem.queryById(id);
        if (childResult != null) {
          return childResult;
        }
      }
    }
    return null;
  }

  @override
  Patch diff(int selfIndex, Node other) {
    if (identical(this, other)) return null;

    if (this.typeIndex != other.typeIndex) {
      // Nodes of different types; always replace
      return new ReplacementPatch(selfIndex, other);
    }

    // TODO: this is super-naive right now
    Element otherEl = other;
    var otherLength = otherEl._children.length;
    var thisLength = this._children.length;
    int sharedLength = min(thisLength, otherLength);

    var patches = <Patch>[]
      ..length = sharedLength;
    for (int i = 0; i < sharedLength; i++) {
      var child = this._children[i];
      var otherChild = otherEl._children[i];
      patches[i] = child.diff(i, otherChild);
    }

    var appends = null;
    if (otherLength > sharedLength) {
      appends = otherEl._children
          .getRange(sharedLength, otherLength);
    }

    var removeFrom = thisLength;
    if (otherLength < sharedLength) {
      removeFrom = otherLength;
    }

    return new ElementPatch(this.typeIndex, selfIndex, patches, appends,
        removeFrom);
  }
}

class ElementPatch extends Patch {
  final List<Patch> patches;
  final List<Node> appends;
  final int removeFrom;

  ElementPatch(int typeIndex, int nodeIndex, this.patches, this.appends, this.removeFrom)
      : super(typeIndex, nodeIndex);
}
