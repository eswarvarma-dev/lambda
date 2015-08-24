part of app.ui;

class Button$View extends ViewObjectBuilder<Button> {
  // Bound elements
  Element _boundElement0;

  // Watched values
  String _property0_0;
  String _text0_0;

  @override
  void build() {
    context = new Button();  // TODO: DI can take place here
    beginHost('Button');
      _boundElement0 = beginElement('div');
        addClass('button');
      endElement();
    endHost();
  }

  @override
  void update() {
    var t0_0 = context.title;
    if (t0_0 != _text0_0) {
      _boundElement0.text = _text0_0 = t0_0;
    }
    var p0_0 = context.id;
    if (p0_0 != _property0_0) {
      _boundElement0.id = _property0_0 = p0_0;
    }
  }
}

class Form$View extends ViewObjectBuilder<Form> {
  Button$View _child0;

  String _property0_0;

  @override
  void build() {
    context = new Form();
    _child0 = new Button$View()..build();
    beginHost('Form');
      beginChild(_child0);
      endElement();
    endHost();
  }

  @override
  void update() {
    var property0_0 = context._actionName;
    if (property0_0 != _property0_0) {
      _child0.context.title = _property0_0 = property0_0;
    }
  }
}

class Menu$View extends ViewObjectBuilder<Menu> {
  FragmentController _fragmentController0;

  @override
  void build() {
    context = new Menu();
    _fragmentController0 = new FragmentController(
      new Foreach(), this, Menu$Fragment0.fragmentFactory);

    beginHost('Menu');
      beginElement('ul');
        addFragmentPlaceholder(_fragmentController0);
      endElement();
    endHost();
  }

  @override
  void update() {
    _fragmentController0.update(this.context.items);
  }
}

class Menu$Fragment0 extends ViewObjectBuilder<Menu> {

  static Menu$Fragment0 fragmentFactory(Menu$View parentView, String item) =>
      new Menu$Fragment0()
        ..context = parentView.context
        ..item = item;

  Element _boundElement0;

  // Variable published by FragmentModelController
  String item;

  String _text0_0;
  String _text0_1;

  @override
  void build() {
    _boundElement0 = beginOwnedElement('li');
    endElement();
  }

  @override
  void update() {
    var t0_0 = context.prefix;
    var t0_1 = item;
    if (t0_0 != _text0_0 || t0_1 != _text0_1) {
      _boundElement0.text = '${_text0_0 = t0_0} - ${_text0_1 = t0_1}';
    }
  }
}
