part of lambda.compiler;

/// Enriches the AST with binding code information, such as field names.
abstract class BaseBinder extends AstVisitor {

  final String _viewClassName;
  int _idx = 0;

  /// Fragments that are direct children of the visited fragment
  final fragments = <Fragment>[];

  BaseBinder(this._viewClassName);

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
    f.fragmentField = '_fragment${_idx}';
    // because fragment class is top-level like all Dart classes, we need to
    // prefix it with parent class name to avoid name collisions
    f.generatedClassName = '${_viewClassName}\$Fragment\$${_idx}';
    _idx++;
    fragments.add(f);
    return true;
  }

  @override
  bool visitDecorator(Decorator d) {
    d.decoratorField = '_decorator${_idx++}';
    return false;
  }
}
