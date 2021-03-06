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

  /// Returns whether the node was consumed along with its children. If `true`,
  /// the node's children will not be visited, the recursion stop at this node.
  bool visitTemplate(Template node) { return false; }
  bool visitHtmlElement(HtmlElement node) { return false; }
  bool visitComponentElement(ComponentElement node) { return false; }
  bool visitProp(Prop node) { return false; }
  bool visitTextInterpolation(TextInterpolation node) { return false; }
  bool visitPlainText(PlainText node) { return false; }
  bool visitAttribute(Attribute node) { return false; }
  bool visitEvent(Event node) { return false; }
  bool visitFragment(Fragment node) { return false; }
  bool visitDecorator(Decorator node) { return false; }

  /// Called immediately after having visited a node and all its children.
  /// Useful for context clean-up and outputting closing tags. This method is
  /// not called for nodes that do not have children.
  void didVisitNode(AstNode visitedNode) {}
}

abstract class AstNode {
  bool accept(AstVisitor visitor) {
    switch (this.runtimeType) {
      case Template:
        return visitor.visitTemplate(this);
      case HtmlElement:
        return visitor.visitHtmlElement(this);
      case ComponentElement:
        return visitor.visitComponentElement(this);
      case Prop:
        return visitor.visitProp(this);
      case TextInterpolation:
        return visitor.visitTextInterpolation(this);
      case PlainText:
        return visitor.visitPlainText(this);
      case Attribute:
        return visitor.visitAttribute(this);
      case Event:
        return visitor.visitEvent(this);
      case Fragment:
        return visitor.visitFragment(this);
      case Decorator:
        return visitor.visitDecorator(this);
      default:
        throw new StateError('Unknown node type: ${this.runtimeType}');
    }
  }
}

abstract class AstNodeWithChildren extends AstNode {
  List<AstNode> get children;

  @override
  bool accept(AstVisitor visitor) {
    visitor.context.push(this);
    if (!super.accept(visitor)) {
      for (AstNode child in children) {
        child.accept(visitor);
      }
    }
    visitor.didVisitNode(this);
    visitor.context.pop();
    return true;
  }
}

class Template extends AstNodeWithChildren {
  final children = <AstNode>[];

  @override
  String toString() => children.join();
}

abstract class Element extends AstNodeWithChildren implements HasProps {
  /// Ordered list of attributes and props
  final attributesAndProps = <DataNode>[];
  final childNodes = <AstNode>[];
  /// Field on the generated [ViewNode] that references an instance of this
  /// element, if the element participates in logic after the view node is
  /// built, such as property binding.
  String nodeField;

  @override
  String get targetObjectField => nodeField;

  List<AstNode> get children =>
      new List<AstNode>.from(attributesAndProps)
        ..addAll(childNodes);

  List<Prop> get props => attributesAndProps.where((p) => p is Prop).toList();

  String _stringify(String tag) =>
    '<${tag}${_stringifyAttributesAndProps()}>'
    '${childNodes.join()}'
    '</${tag}>';

  String _stringifyAttributesAndProps() => attributesAndProps.isEmpty
    ? ''
    : attributesAndProps.map((attrOrProp) => ' ${attrOrProp}').join();
}

abstract class HasProps {
  List<Prop> get props;

  /// The field referncing the object that's the target for setting the props.
  String get targetObjectField;
}

class HtmlElement extends Element {
  String tag;
  bool isBound = false;

  @override
  String toString() => super._stringify(tag);
}

class ComponentElement extends Element {
  String type;

  @override
  String toString() => super._stringify(type);
}

class Fragment extends AstNodeWithChildren {
  String type;
  Expression inputExpression;
  final outVars = <String>[];
  final childNodes = <AstNode>[];
  Fragment parentFragment;

  String generatedClassName;
  String fragmentField;

  List<AstNode> get children => childNodes;

  String _stringifyOutVars() => outVars.isNotEmpty
      ? ' -> ${outVars.join(', ')}'
      : '';

  @override
  String toString() =>
    '{% ${type} (${inputExpression}${_stringifyOutVars()}) %}'
    '${childNodes.join()}'
    '{% /${type} %}';
}

class Decorator extends AstNodeWithChildren implements HasProps {
  String type;
  List<Prop> props;
  String decoratorField;

  @override
  String get targetObjectField => decoratorField;

  @override
  List<AstNode> get children => props;

  @override
  String toString() =>
    '{# ${type} #}';
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
  Expression expression;
  String valueField;

  @override
  String toString() => '[${property}]="${expression}"';
}

class Event extends DataNode {
  String type;
  String statement;
  String subscriptionField;

  @override
  String toString() => '(${type})="${statement}"';
}

class TextInterpolation extends AstNode {
  Expression expression;
  /// Field that references to the text node.
  String nodeField;
  /// Field that references the last seen string value.
  String valueField;

  @override
  String toString() => '{{$expression}}';
}

class PlainText extends AstNode {
  String text;

  @override
  String toString() => text;
}

class Expression {
  /// Whether the expression is evaluated within the context of `this`.
  /// Currently such expression must begin with `this.`, e.g. `this.foo.bar`.
  bool isThis = false;

  /// Terms participating in a dot call chain expression, e.g. in `foo.bar.baz`
  /// the terms are `foo`, `bar` and `baz`.
  final terms = <String>[];

  String _thisPrefix() => !isThis
    ? ''
    : terms.isEmpty
      ? 'this'
      : 'this.';

  @override
  String toString() => '${_thisPrefix()}${terms.join('.')}';
}
