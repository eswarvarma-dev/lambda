library lambda;

import 'dart:html';
export 'dart:html';
import 'dart:async';

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

typedef ViewNode FragmentFactory(ViewNode parentView, dynamic data);

class FragmentController {
  final FragmentModelController _controller;
  final ViewNode _parentView;
  final FragmentFactory _factory;
  final _fragments = <ViewNode>[];
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
      _fragments.add(fragment);
    }
  }
}

final _buildStack = new List<Element>(100);
int _buildStackPointer = -1;

abstract class ViewNode<C> {
  C context;
  Element hostElement;
  List<Node> ownedNodes;

  void build();
  void update();

  void detach() {
    if (hostElement != null) {
      hostElement.remove();
    }
    if (ownedNodes != null && ownedNodes.isNotEmpty) {
      final len = ownedNodes.length;
      for (int i = 0; i < len; i++) {
        ownedNodes[i].remove();
      }
    }
  }
}

/// A utility for building [ViewNode]s.
abstract class ViewNodeBuilder<C> extends ViewNode<C> {

  List<StreamSubscription> _subscriptions;

  void subscribe(Stream stream, Function callback) {
    trackSubscription(stream.listen(callback));
  }
  void trackSubscription(StreamSubscription sub) {
    if (_subscriptions == null) _subscriptions = <StreamSubscription>[];
    _subscriptions.add(sub);
  }

  void cleanupSubscriptions() {
    for (int i = 0; i < _subscriptions.length; i++) {
      _subscriptions[i].cancel();
    }
    _subscriptions.clear();
  }

  void beginHost(String tag) {
    assert(_buildStack.isEmpty);
    assert(_buildStackPointer == 0);
    hostElement = new Element.tag(tag);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = hostElement;
  }

  void endHost() {
    assert(_buildStackPointer == 0);
    _buildStack.fillRange(0, 100);
    _buildStackPointer = -1;
  }

  Element beginElement(String tag, {Map<String, String> attrs}) {
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

  Element beginChild(ViewNode child) {
    Element childHostElement = child.hostElement;
    Element parent = _buildStack[_buildStackPointer];
    parent.append(childHostElement);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = childHostElement;
    return childHostElement;
  }

  Element addFragmentPlaceholder(FragmentModelController fmc) {
    Element placeholder = new TemplateElement();
    Element parent = _buildStack[_buildStackPointer];
    parent.append(placeholder);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = placeholder;
    final fc = new FragmentController(fmc, this, /*TODO*/null);
    fc.placeholder = placeholder;
    return placeholder;
  }

  void addClass(String className) {
    _buildStack[_buildStackPointer].classes.add(className);
  }

  void endElement() {
    _buildStackPointer--;
  }

  Node addTextInterpolation() {
    Element parent = _buildStack[_buildStackPointer];
    Text textNode = new Text(' ');
    parent.append(textNode);
    return textNode;
  }

  Node addText(String text) {
    Element parent = _buildStack[_buildStackPointer];
    Text textNode = new Text(text);
    parent.append(textNode);
    return textNode;
  }
}
