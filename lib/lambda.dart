library lambda;

import 'dart:html';
export 'dart:html';
import 'dart:async';

import 'zone.dart';

ViewNode updateUiAutomatically(ViewNode viewFactory()) {
  final zone = new NgZone();
  zone.overrideOnErrorHandler((err, StackTrace stackTrace) {
    print('ERROR: $err\nSTACK:\n$stackTrace');
  });
  return zone.run(() {
    final view = viewFactory();
    zone.overrideOnTurnDone(() {
      view.update();
    });
    try {
      view.build();
    } catch(e, s) {
      print('ERROR: ${e}\nSTACK:\n${s}');
    }
    return view;
  });
}

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

/// A decorator is applied to an element (target) and it can alter the
/// element's properties according to whatever props are passed to it.
abstract class Decorator {
  final Element target;
  Decorator(this.target);
}

/// Used within the `{% ... %}` template blocks. Controls the creation of
/// fragments of templates enclosed within the fragment block by converting
/// an input value into a [List] of items, each corresponding to an instance
/// of a template fragment.
abstract class FragmentController<I, F extends Function> {
  final F fragmentFactory;
  final _fragments = <ViewNode>[];
  Node placeholder;
  dynamic context;
  ViewNode parentFragment;

  FragmentController(this.fragmentFactory);

  List<ViewNode> get fragments => _fragments;

  /// Called during change detection.
  void render(I input);

  void updateFragments() {
    for (int i = 0; i < _fragments.length; i++) {
      _fragments[i].update();
    }
  }

  void insert(int index, ViewNode f) {
    _insertNodes(index, f);
    _fragments.insert(index, f);
  }

  void _insertNodes(int index, ViewNode f) {
    f.parentFragment = parentFragment;
    Node anchor = placeholder;
    if (index < _fragments.length) {
      // TODO: handle the case when first thing is another fragment
      anchor = _fragments[index].rootNodes.first;
    }
    final nodes = f.rootNodes;
    final parent = anchor.parent;
    for (int i = 0; i < nodes.length; i++) {
      parent.insertBefore(nodes[i], anchor);
    }
  }

  void replace(int index, ViewNode f) {
    _insertNodes(index, f);
    _fragments[index].detach();
    _fragments[index] = f;
  }

  void append(ViewNode f) {
    _insertNodes(_fragments.length, f);
    _fragments.add(f);
  }

  void remove(int index) {
    _fragments.removeAt(index).detach();
  }

  void clear() {
    while (_fragments.length > 0) {
      this.remove(0);
    }
    assert(this._fragments.isEmpty);
  }
}

abstract class ViewNode<C> {
  C context;
  Element hostElement;
  List<Node> _rootNodes;
  ViewNode parentFragment;

  List<Node> get rootNodes => _rootNodes;

  void addRootNode(Node node) {
    if (_rootNodes == null) _rootNodes = [];
    _rootNodes.add(node);
  }

  void build();
  void update();

  // TODO: detach nested fragments
  void detach() {
    if (hostElement != null) {
      hostElement.remove();
    }
    if (rootNodes != null && rootNodes.isNotEmpty) {
      final len = rootNodes.length;
      for (int i = 0; i < len; i++) {
        rootNodes[i].remove();
      }
    }
  }
}

/// A utility for building [ViewNode]s.
abstract class ViewNodeBuilder<C> extends ViewNode<C> {

  List _buildStack = <Element>[];
  int _buildStackPointer = -1;

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

  void beginHost(String tag, context) {
    assert(_buildStack.isEmpty);
    assert(_buildStackPointer == -1);
    assert(context != null);
    this.context = context;
    hostElement = new Element.tag(tag);
    _pushNode(hostElement);
  }

  Element beginElement(String tag) {
    Element element = new Element.tag(tag);
    _appendNode(element);
    _pushNode(element);
    return element;
  }

  ViewNode beginChild(ViewNode child) {
    child.build();
    Element childHostElement = child.hostElement;
    _appendNode(childHostElement);
    _pushNode(childHostElement);
    return child;
  }

  Node addFragmentController(FragmentController fc) {
    fc.parentFragment = this;
    Comment placeholder = new Comment();
    _appendNode(placeholder);
    fc.placeholder = placeholder;
    fc.context = this.context;
    return placeholder;
  }

  void setAttribute(String name, String value) {
    // TODO: instead of maintaining build stack, just hold on to the current
    // element being built. Looks like we don't need full breadcrumb trail.
    // Fewer array lookups this way.
    Element element = _buildStack[_buildStackPointer];
    element.setAttribute(name, value);
  }

  void addClass(String className) {
    _buildStack[_buildStackPointer].classes.add(className);
  }

  void endElement() {
    _buildStackPointer--;
  }

  void endBuild() {
    _buildStack = null;
    _buildStackPointer = -1;
  }

  Node addTextInterpolation() {
    Text textNode = new Text(' ');
    _appendNode(textNode);
    return textNode;
  }

  Node addText(String text) {
    Text textNode = new Text(text);
    _appendNode(textNode);
    return textNode;
  }

  _appendNode(Node child) {
    assert(child != null);
    if (_buildStackPointer == -1) {
      super.addRootNode(child);
    } else {
      Element parent = _buildStack[_buildStackPointer];
      assert(parent != null);
      parent.append(child);
    }
  }

  _pushNode(Node node) {
    _buildStackPointer++;
    if (_buildStackPointer < _buildStack.length) {
      _buildStack[_buildStackPointer] = node;
    } else {
      _buildStack.add(node);
    }
  }
}
