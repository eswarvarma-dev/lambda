library lambda.ast;

abstract class AstVisitor {
  void visitTemplate(Template node) {}
  void visitHtmlElement(HtmlElement node) {}
  void visitComponentElement(ComponentElement node) {}
  void visitPropertyBinding(PropertyBinding node) {}
  void visitTextInterpolation(TextInterpolation node) {}
  void visitPlainText(PlainText node) {}
}

abstract class AstNode {
  void accept(AstVisitor visitor) {
    switch (this.runtimeType) {
      case Template:
        visitor.visitTemplate(this);
        break;
      case HtmlElement:
        visitor.visitHtmlElement(this);
        break;
      case ComponentElement:
        visitor.visitComponentElement(this);
        break;
      case PropertyBinding:
        visitor.visitPropertyBinding(this);
        break;
      case TextInterpolation:
        visitor.visitTextInterpolation(this);
        break;
      default:
        throw new StateError('Unknown node type: ${this.runtimeType}');
    }
  }
}

abstract class AstNodeWithChildren extends AstNode {
  Iterable<AstNode> get children;

  @override
  void accept(AstVisitor visitor) {
    super.accept(visitor);
    for (AstNode child in children) {
      child.accept(visitor);
    }
  }
}

class Template extends AstNodeWithChildren {
  final children = <AstNode>[];

  @override
  String toString() => children.join();
}

abstract class Element extends AstNodeWithChildren {
  Map<String, String> attributes;
  List<PropertyBinding> propertyBindings;
  List<AstNode> childNodes;

  Iterable<AstNode> get children =>
      new List<AstNode>.from(propertyBindings)..addAll(childNodes);

  String _stringify(String tag) =>
    '<${tag}${_stringifyAttributes()}${_stringifyProperties()}>'
    '${childNodes.join()}'
    '</${tag}>';

  String _stringifyAttributes() => attributes.isEmpty
    ? ''
    : attributes.keys.map((k) => ' ${k}="${attributes[k]}"').join();

  String _stringifyProperties() => propertyBindings.isEmpty
    ? ''
    : propertyBindings
        .map((PropertyBinding b) => ' ${b}')
        .join();
}

class HtmlElement extends Element {
  String tag;

  @override
  String toString() => super._stringify(tag);
}

class ComponentElement extends Element {
  String type;

  @override
  String toString() => super._stringify(type);
}

class PropertyBinding extends AstNode {
  String propertyName;
  String expression;

  @override
  String toString() => '[${propertyName}]="${expression}"';
}

class TextInterpolation extends AstNode {
  String expression;

  @override
  String toString() => '{{expression}}';
}

class PlainText extends AstNode {
  String text;

  @override
  String toString() => text;
}
