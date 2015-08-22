part of app.ui;

final _buildStack = <Element>[];
int _buildStackPointer = -1;

abstract class ViewObject<C> {
  Element hostElement;
  C context;

  void build();
  void update();

  void pushHost(String tag) {
    assert(_buildStack.isEmpty);
    assert(_buildStackPointer == 0);
    hostElement = new Element.tag(tag);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = hostElement;
  }

  Element pushElement(String tag) {
    Element element = new Element.tag(tag);
    Element parent = _buildStack[_buildStackPointer];
    parent.append(element);
    _buildStackPointer++;
    _buildStack[_buildStackPointer] = element;
    return element;
  }

  void addClass(String className) {
    _buildStack[_buildStackPointer].classes.add(className);
  }

  void pop() {
    _buildStackPointer--;
  }

  void popHost() {
    _buildStack.clear();
    assert(_buildStackPointer == 0);
    _buildStackPointer = -1;
  }
}

class Button$View extends ViewObject<Button> {
  Element _e0;
  String _t0_0;

  @override
  void build() {
    pushHost('Button');
      _e0 = pushElement('div');
        addClass('button');
      pop();
    popHost();
  }

  @override
  void update() {
    var t0_0 = context.title;
    if (t0_0 != _t0_0) {
      _e0.text = _t0_0 = t0_0;
    }
  }
}

class Form$View extends ViewObject<Form> {
  @override
  void build() {

  }

  @override
  void update() {

  }
}
