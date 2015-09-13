part of lambda.compiler;

/// Generates bound fields.
abstract class BaseFieldGeneratorVisitor extends AstVisitor {
  final _buf = new StringBuffer();

  String get code => _buf.toString();

  @override
  bool visitHtmlElement(HtmlElement elem) {
    // Create fields only for bound nodes
    if (elem.isBound) {
      _emit(' Element ${elem.nodeField};');
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    _emit(' ${elem.type} ${elem.nodeField};');
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    _emit(' Text ${txti.nodeField};');
    _emit(' String ${txti.valueField};');
    return false;
  }

  @override
  bool visitProp(Prop p) {
    _emit(' var ${p.valueField};');
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    _emit(' var ${f.fragmentField};');
    return true;
  }

  @override
  bool visitDecorator(Decorator d) {
    _emit(' ${d.type} ${d.decoratorField};');
    return false;
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}
