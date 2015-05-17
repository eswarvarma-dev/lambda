part of lambda.browser.node_type;

class ElementNodeType extends NodeType<Element> {
  static final _registeredTags = <String, ElementNodeType>{};

  final String tagName;

  ElementNodeType._private(this.tagName);

  factory ElementNodeType(String tagName) {
    // Dedupe element types by tag name; there's no need to have two types for
    // the same tag, at least for now.
    var type = _registeredTags[tagName];
    if (type == null) {
      type = _registeredTags[tagName] = new ElementNodeType._private(tagName);
    }
    return type;
  }

  @override
  void applyPatch(dom.Element target, ElementPatch patch) {
    if (patch.patches != null) {
      for (int i = 0; i < patch.patches.length; i++) {
        var childPatch = patch.patches[i];
        var childNodeType = NodeType.forPatch(childPatch);
        var childNode = target.childNodes[childPatch.index];
        if (childPatch is ReplacementPatch) {
          target.childNodes[childPatch.index] =
              childNodeType.createNativeNode(childPatch.replacement);
        } else {
          childNodeType.applyPatch(childNode, childPatch);
        }
      }
    }

    if (patch.appends != null) {
      for (int i = 0; i < patch.appends.length; i++) {
        var append = patch.appends[i];
        target.append(NodeType.forNode(append).createNativeNode(append));
      }
    } else {
      target.childNodes.removeRange(patch.removeFrom, target.childNodes.length);
    }
  }

  @override
  dom.Element createNativeNode(Element elem) {
    ElementNodeType type = NodeType.forNode(elem);
    var domEl = new dom.Element.tag(type.tagName);
    elem.attributes.forEach((String name, String value) {
      domEl.setAttribute(name, value);
    });
    if (elem.hasChildren) {
      for (int i = 0; i < elem.children.length; i++) {
        var child = elem.children[i];
        domEl.append(NodeType.forNode(child).createNativeNode(child));
      }
    }
    return domEl;
  }

  @override
  String toXml(Element elem) {
    ElementNodeType type = NodeType.forNode(elem);

    final sb = new StringBuffer('<');
    sb.write(type.tagName);

    if (elem.hasAttributes) {
      elem.attributes.forEach((String name, String value) {
        sb
          ..write(' ')
          ..write(name)
          ..write('="')
          ..write(value)
          ..write('"');
      });
    }

    sb.write('>');

    if (elem.hasChildren) {
      elem.children
        .map((Node child) => NodeType.forNode(child).toXml(child))
        .forEach(sb.write);
    }

    sb
      ..write('</')
      ..write(type.tagName)
      ..write('>');
    return sb.toString();
  }
}
