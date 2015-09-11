part of lambda.compiler;

/// Generates code for the `update` method.
abstract class BaseUpdateMethodVisitor extends AstVisitor {
  final _buf = new StringBuffer();

  String get code => _buf.toString();

  @override
  bool visitHtmlElement(HtmlElement elem) {
    if (elem.isBound) {
      _emitPropChangeDetection(elem);
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    _emitPropChangeDetection(elem);
    return false;
  }

  void _emitPropChangeDetection(Element elem) {
    elem.attributesAndProps
      .where((n) => n is Prop)
      .forEach((Prop p) {
        _emit(' _tmp = context.${p.expression};');
        _emit(' if (!identical(_tmp, ${elem.nodeField})) {');
        _emit('   ${elem.nodeField}.${p.property} = ${p.valueField} = _tmp;');
        _emit(' }');
      });
  }

  @override
  bool visitTextInterpolation(TextInterpolation ti) {
    _emit(' _tmp = \'\${context.${ti.expression}}\';');
    _emit(' if (!identical(_tmp, ${ti.valueField})) {');
    _emit('   ${ti.nodeField}.text = ${ti.valueField} = _tmp;');
    _emit(' }');
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    _emit(' _tmp = context.${f.inputExpression};');
    _emit(' ${f.fragmentField}.render(${f.inputValueField} = _tmp);');
    _emit(' ${f.fragmentField}.updateFragments();');
    return true;
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}

String snakeCase(String s) {
  final buf = new StringBuffer(s[0].toLowerCase());
  for (int i = 1; i < s.length; i++) {
    var lowerCaseChar = s[i].toLowerCase();
    if (lowerCaseChar != s[i]) {
      buf.write('-');
    }
    buf.write(lowerCaseChar);
  }
  return buf.toString();
}
