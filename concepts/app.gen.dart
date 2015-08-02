part of app.ui;

class Button$Component extends Component {
  static final _template = TemplateRegistry.get(
    '''<div class="button" _></div>''');

  final Button context;

  Button$Component(this.context);

  @override
  Node render() {
    return new Projection(_template.id, [
      new Insertion(0, text(context.title))
    ]);
  }
}

class Form$Component extends Component {
  static final _template = TemplateRegistry.get(
    '''<form><_ _></_></form>''');

  final Form context;
  final _$0 = new Button$Component(new Button());  // zero-th "bound" element

  Form$Component(this.context);

  @override
  Node render() {
    _$0.context.title = context._actionName;
    return new Projection(_template.id, [
      new Insertion(0, _$0.render())
    ]);
  }
}

class Menu$Component extends Component {
  static final _template = TemplateRegistry.get(
    '''<ul><_ _></_></ul>''');

  final Menu context;
  For _$0;

  Menu$Component(this.context) {
    _$0 = new For((data) => new Menu$Fragment$0(context, data));
  }

  @override
  Node render() {
    return new Projection(
        _template.id,
        _$0.render(context.items).map((node) => new Insertion(0, node))
    );
  }
}

// Component fragment inside the for loop
class Menu$Fragment$0 extends Component {
  static final _template = TemplateRegistry.get(
    '''<li _></li>''');

  final Menu context;
  final String item;

  Menu$Fragment$0(this.context, this.item);

  @override
  Node render() {
    return new Projection(_template.id, [
      new Insertion(0, text('${context.prefix} - ${item}'))
    ]);
  }
}

class Table$Component extends Component {
  static final _template = TemplateRegistry.get(
    '''<table><_ _></_></table>''');

  final Table context;
  For _$0;

  Table$Component(this.context) {
    _$0 = new For((data) => new Table$Fragment$0(context, data));
  }

  @override
  Node render() {
    return new Projection(
        _template.id,
        _$0.render(context.rows).map((node) => new Insertion(0, node))
    );
  }
}

class Table$Fragment$0 extends Component {
  static final _template = TemplateRegistry.get(
    '''<tr><td _></td><_ _></_></tr>''');

  final Table context;
  final Map<String, dynamic> row;
  For _$1;

  Table$Fragment$0(this.context, this.row) {
    _$1 = new For((data) => new Table$Fragment$1(context, row['num'], data));
  }

  @override
  Node render() {
    return new Projection(
        _template.id,
        [new Insertion(0, text('${row['num']}'))]
          ..addAll(_$1.render(row['num']).map((node) => new Insertion(1, node)))
    );
  }
}

class Table$Fragment$1 extends Component {
  static final _template = TemplateRegistry.get(
    '''<tr><td _></td></tr>''');

  final Table context;
  final Map<String, dynamic> row;
  final String col;

  Table$Fragment$1(this.context, this.row, this.col);

  @override
  Node render() {
    return new Projection(_template.id, [
      new Insertion(0, text('${row['pref']} - ${col}'))
    ]);
  }
}
