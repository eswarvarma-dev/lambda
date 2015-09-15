part of lambda.compiler;

/// Generates code for the `build` method.
abstract class BaseBuildMethodVisitor extends AstVisitor {
  final _buf = new StringBuffer();
  List<Decorator> _pendingDecorators = <Decorator>[];

  String get code => _buf.toString();

  @override
  bool visitHtmlElement(HtmlElement elem) {
    final tag = elem.tag;
    bool hasEvents = elem.attributesAndProps.any((p) => p is Event);
    if (elem.isBound) {
      _emit(' ${elem.nodeField} = ');
    }
    // If we're listening to events on this element, store the element reference
    // in a local variable in order to create subscriptions.
    else if (hasEvents || _pendingDecorators.isNotEmpty) {
      _emit(' Element ${elem.nodeField} = ');
    }
    _emit(" beginElement('${tag}');");
    _emitAttributes(elem);
    if (hasEvents) {
      elem.attributesAndProps.where((n) => n is Event).forEach((Event e) {
        _emitSubscription(elem.nodeField, e);
      });
    }
    if (_pendingDecorators.isNotEmpty) {
      _pendingDecorators.forEach((Decorator d) {
        _emit(' ${d.decoratorField} = new ${d.type}(${elem.nodeField});');
      });
      _pendingDecorators = <Decorator>[];
    }
    return false;
  }

  @override
  bool visitComponentElement(ComponentElement elem) {
    final tag = elem.type;
    _emit(' ${elem.nodeField} = beginChild(${tag}.viewFactory());');
    _emitAttributes(elem);
    bool hasEvents = elem.attributesAndProps.any((p) => p is Event);
    if (hasEvents) {
      elem.attributesAndProps.where((n) => n is Event).forEach((Event e) {
        _emitSubscription(elem.nodeField, e);
      });
    }
    return false;
  }

  _emitSubscription(String nodeVariable, Event event) {
    _emit(' subscribe(');
    _emit('   ${nodeVariable}.on[\'${event.type}\'],');
    _emit('   context.${event.statement}');
    _emit(' );');
  }

  @override
  bool visitPlainText(PlainText ptxt) {
    final cleanText = ptxt.text.trim();
    // TODO: space between text interpolations must not be collapsed
    if (cleanText.isNotEmpty) {
      _emit(" addText('''${ptxt.text}''');");
    }
    return false;
  }

  @override
  bool visitTextInterpolation(TextInterpolation txti) {
    _emit(' ${txti.nodeField} = addTextInterpolation();');
    return false;
  }

  @override
  bool visitFragment(Fragment f) {
    _emit(' addFragmentController(${f.fragmentField} =');
    _emit(' ${f.generatedClassName}.create());');
    return true;
  }

  @override
  bool visitDecorator(Decorator d) {
    _pendingDecorators.add(d);
    return false;
  }

  @override
  void didVisitNode(AstNode node) {
    if (node is Element) {
      _emit(' endElement();');
    }
  }

  void _emitAttributes(Element elem) {
    elem.attributesAndProps
      .where((n) => n is Attribute)
      .forEach((Attribute attr) {
        _emit(" setAttribute('''${attr.name}''', '''${attr.value}''');");
      });
  }

  void _emit(Object o) {
    _buf.write(o);
  }
}
