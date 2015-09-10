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
abstract class FragmentController<I, F extends Function> {
  final F fragmentFactory;
  final _fragments = <ViewNode>[];
  Node placeholder;

  FragmentController(this.fragmentFactory);

  updateFragments() {
    for (int i = 0; i < _fragments.length; i++) {
      _fragments[i].update();
    }
  }

  insert(int index, ViewNode f) {
    Node anchor = placeholder;
    if (index < _fragments.length) {
      anchor = _fragments.last.rootNodes.first;
    }
    final nodes = f.rootNodes;
    final parent = anchor.parent;
    for (int i = 0; i < nodes.length; i++) {
      parent.insertBefore(nodes[i], anchor);
    }
    _fragments.insert(index, f);
  }

  remove(int index) {
    _fragments[index].detach();
  }

  /// Called during change detection.
  void render(I input);
}

final _buildStack = new List<Element>(100);
int _buildStackPointer = -1;

abstract class ViewNode<C> {
  C context;
  Element hostElement;
  List<Node> _rootNodes;

  List<Node> get rootNodes => _rootNodes;

  void addRootNode(Node node) {
    if (_rootNodes == null) _rootNodes = [];
    _rootNodes.add(node);
  }

  void build();
  void update();

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
    _appendNode(element);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = element;
    return element;
  }

  Element beginChild(ViewNode child) {
    Element childHostElement = child.hostElement;
    _appendNode(childHostElement);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = childHostElement;
    return childHostElement;
  }

  Node addFragmentPlaceholder(FragmentController fc) {
    Comment placeholder = new Comment();
    _appendNode(placeholder);
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
    if (_buildStackPointer == -1) {
      addRootNode(child);
    } else {
      Element parent = _buildStack[_buildStackPointer];
      parent.append(child);
    }
  }
}
