library app.ui;

import 'package:lambda/lambda.dart';
import 'foreach.dart';

@LambdaUi(uses: const [Foreach])

part 'app.gen.dart'; // generated part

// Component: reusable & composable piece of interactive DOM
@View('<div [id]="id" class="button">{{title}}</div>')
class Button {
  String id;
  String title;
}

// Example: composition
@View('''
<form>
  <Button [title]="_actionName" />
</form>
''')
class Form {
  String _actionName;
}

// Fragments: control UI structure
@View('''
<ul>
  {% For (items -> item) %}
    <li>{{prefix}} - {{item}}</li>
  {% /For %}
</ul>
''')
class Menu {
  String prefix;
  List<String> items;
}

// Example: fragments can nest
@View('''
<table>
  {% For (rows -> row) %}
    <tr>
      <td>{{row['num']}}</td>
      {% For (row['cols'] -> col) %}
        <td>{{row['pref']}} - {{col}}</td>
      {% /For %}
    </tr>
  {% /For %}
</table>
''')
class Table {
  List<Map<String, dynamic>> rows = [
    { 'num' : 1, 'pref' : 'a', 'cols' : [ 'foo', 'bar', 'baz' ]},
    { 'num' : 2, 'pref' : 'b', 'cols' : [ 'qux', 'quux', 'cruft' ]},
  ];
}

// Decorators: control element properties
@View('''
<div>
  @Material(theme: currentTheme)
  <input type="text">
</div>
''')
class MaterialInput {
  var currentTheme;
}

// TODO: DI
// TODO: events
// TODO: property adapters - decorators?
// TODO: imperative views
// TODO: child queries
// TODO: locals
