library lambda.ast;

import 'dart:collection' show UnmodifiableListView;

class Breadcrumbs<E> {
  final _list = <E>[];

  void push(E element) {
    _list.add(element);
  }

  E pop() {
    return _list.removeLast();
  }

  UnmodifiableListView get path => new UnmodifiableListView(_list);
}

abstract class AstVisitor {
  /// Path to the parent node of the [AstNode] currently being visited.
  final context = new Breadcrumbs<AstNodeWithChildren>();

  void visitTemplate(Template node) {}
  void visitHtmlElement(HtmlElement node) {}
  void visitComponentElement(ComponentElement node) {}
  void visitProp(Prop node) {}
  void visitTextInterpolation(TextInterpolation node) {}
  void visitPlainText(PlainText node) {}
  void visitAttribute(Attribute node) {}

  /// Called immediately after having visited a node and all its children.
  /// Useful for context clean-up and outputting closing tags. This method is
  /// not called for nodes that do not have children.
  void didVisitNode(AstNode visitedNode) {}
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
      case Prop:
        visitor.visitProp(this);
        break;
      case TextInterpolation:
        visitor.visitTextInterpolation(this);
        break;
      case PlainText:
        visitor.visitPlainText(this);
        break;
      case Attribute:
        visitor.visitAttribute(this);
        break;
      default:
        throw new StateError('Unknown node type: ${this.runtimeType}');
    }
  }
}

abstract class AstNodeWithChildren extends AstNode {
  List<AstNode> get children;

  @override
  void accept(AstVisitor visitor) {
    visitor.context.push(this);
    super.accept(visitor);
    for (AstNode child in children) {
      child.accept(visitor);
    }
    visitor.didVisitNode(this);
    visitor.context.pop();
  }
}

class Template extends AstNodeWithChildren {
  final children = <AstNode>[];

  @override
  String toString() => children.join();
}

abstract class Element extends AstNodeWithChildren {
  /// Ordered list of attributes and props
  final attributesAndProps = <DataNode>[];
  final childNodes = <AstNode>[];

  List<AstNode> get children =>
      new List<AstNode>.from(attributesAndProps)
        ..addAll(childNodes);

  String _stringify(String tag) =>
    '<${tag}${_stringifyAttributesAndProps()}>'
    '${childNodes.join()}'
    '</${tag}>';

  String _stringifyAttributesAndProps() => attributesAndProps.isEmpty
    ? ''
    : attributesAndProps.map((attrOrProp) => ' ${attrOrProp}').join();
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

/// Superclass for all types of nodes that deal with passing data.
abstract class DataNode extends AstNode {}

class Attribute extends DataNode {
  final String name;
  final String value;

  Attribute(this.name, this.value);

  @override
  String toString() => '${name}="${value}"';
}

class Prop extends DataNode {
  String property;
  String expression;

  @override
  String toString() => '[${property}]="${expression}"';
}

class Event extends DataNode {
  String type;
  String statement;

  @override
  String toString() => '(${type})="${statement}"';
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
