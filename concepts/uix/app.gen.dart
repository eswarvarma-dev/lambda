part of app.ui;

class Button$View extends LambdaView<Button> {
  @override
  build() {
    return vElement('div', classes: ['button'])(context.title);
  }
}

class Form$View extends LambdaView<Form> {
  @override
  build() {
    final _0 = new Button()
      ..title = context._actionName;
    return vElement('form')(
      vComponent(() => new Button$View()..context = _0)
    );
  }
}

class Menu$View extends LambdaView<Menu> {
  @override
  build() {
    final _0 = new Foreach(this.context);
    return vElement('ul')(
      renderFragment(_0, $Menu$Fragment$0, context.items)
    );
  }
}

// Component fragment inside the for loop
Menu$Fragment$0 $Menu$Fragment$0() => new Menu$Fragment$0();
class Menu$Fragment$0 extends Fragment<Menu, String> {
  @override
  VNode build() {
    return vElement('li')('${context.prefix} - ${data}');
  }
}

class Table$View extends LambdaView<Table> {
  @override
  VNode build() {
    final _0 = new Foreach(this.context);
    return vElement('table')(
      _0.render(context.rows)
    );
  }
}

Table$Fragment$0 $Table$Fragment$0() => new Table$Fragment$0();
class Table$Fragment$0 extends Fragment<Table, Map<String, String>> {
  @override
  VNode build() {
    final _0 = new Foreach(this.context);
    return vElement('tr')(
      vElement('td')('''${data['num']}'''),
      renderFragment(_0, $Table$Fragment$1, data['cols'])
    );
  }
}

Table$Fragment$1 $Table$Fragment$1() => new Table$Fragment$1();
class Table$Fragment$1 extends Fragment<Table, String> {
  @override
  VNode build() {
    return vElement('td')('''${parent.data['pref']} - ${data}''');
  }
}

class MaterialInput$View extends LambdaView<MaterialInput> {
  @override
  VNode build() {
    return vElement('div')(
      vElement('input', attrs: {
        Attr.type: 'text'
      })
    );
  }
}
