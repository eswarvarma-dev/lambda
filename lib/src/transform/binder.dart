part of lambda.compiler;

/// Enriches the AST with binding code information, such as field names.
abstract class BaseBinder extends AstVisitor {

  int _idx = 0;

  @override
  bool visitHtmlElement(HtmlElement elem) {
    elem
      ..isBound = elem.attributesAndProps.any((DataNode node) => node is Prop)
      ..nodeField = '_element${_idx++}';
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    elem.nodeField = '_child${_idx++}';
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    txti.nodeField = '_textInterpolationNode${_idx}';
    txti.valueField = '_textInterpolationValue${_idx}';
    _idx++;
    return false;
  }

  @override
  bool visitProp(Prop p) {
    p.valueField = '_prop${_idx++}';
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    f.fragmentField = '_fragment${_idx++}';
    return true;
  }
}
