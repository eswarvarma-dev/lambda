library lambda;

import 'dart:html';
export 'dart:html';

/// A noop annotation that causes Dart analyzer to shut up about "unused"
/// imports. Because Lambda template language can refer to symbols, it requires
/// that those symbols are imported.
class LambdaUi {
  const LambdaUi({List uses});
}

/// This annotation describes the UI structure of a component using Angular-ish
/// template language.
class View {
  final String code;
  const View(this.code);
}

/// Used within the `<% ... %>` template blocks. Controls the creation of
/// fragments of templates enclosed within the fragment block by converting
/// an input value into a [List] of items, each corresponding to an instance
/// of a template fragment.
abstract class FragmentModelController<C, T, E> {
  List<E> render(T input);
}

typedef ViewObject FragmentFactory(ViewObject parentView, dynamic data);

class FragmentController {
  final FragmentModelController _controller;
  final ViewObject _parentView;
  final FragmentFactory _factory;
  final _fragments = <ViewObject>[];
  Element placeholder;

  FragmentController(this._controller, this._parentView, this._factory);

  void update(dynamic input) {
    // TODO: super naive implementation
    List items = _controller.render(input);
    for (int i = 0; i < _fragments.length; i++) {
      _fragments[i].detach();
    }
    _fragments.clear();
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final fragment = _factory(_parentView, item);
    }
  }
}

final _buildStack = <Element>[];
int _buildStackPointer = -1;

abstract class ViewObject<C> {
  C context;
  Element hostElement;
  List<Node> ownedNodes;

  void build();
  void update();
}

abstract class ViewObjectBuilder<C> extends ViewObject<C> {

  void beginHost(String tag) {
    assert(_buildStack.isEmpty);
    assert(_buildStackPointer == 0);
    hostElement = new Element.tag(tag);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = hostElement;
  }

  void endHost() {
    assert(_buildStackPointer == 0);
    _buildStack.clear();
    _buildStackPointer = -1;
  }

  Element beginElement(String tag) {
    Element element = new Element.tag(tag);
    Element parent = _buildStack[_buildStackPointer];
    parent.append(element);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = element;
    return element;
  }

  Element beginOwnedElement(String tag) {
    Element element = new Element.tag(tag);
    Element parent = _buildStack[_buildStackPointer];
    parent.append(element);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = element;
    if (_buildStackPointer == 0) {
      ownedNodes.add(element);
    }
    return element;
  }

  Element beginChild(ViewObject child) {
    Element childHostElement = child.hostElement;
    Element parent = _buildStack[_buildStackPointer];
    parent.append(childHostElement);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = childHostElement;
    return childHostElement;
  }

  Element addFragmentPlaceholder(FragmentController controller) {
    Element placeholder = new TemplateElement();
    Element parent = _buildStack[_buildStackPointer];
    parent.append(placeholder);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = placeholder;
    controller.placeholder = placeholder;
    return placeholder;
  }

  void addClass(String className) {
    _buildStack[_buildStackPointer].classes.add(className);
  }

  void endElement() {
    _buildStackPointer--;
  }
}
