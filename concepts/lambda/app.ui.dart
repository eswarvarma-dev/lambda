library app.ui;

@Uses(const [Foreach])
import 'package:lambda/lambda.dart';
import 'package:lambda/foreach.dart';

part 'app.gen.dart'; // generated part

// Component: reusable & composable piece of interactive DOM
@View('<div class="button">{{title}}</div>')
class Button {
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
  <% Foreach(items) : String item %>
    <li>{{prefix}} - {{item}}</li>
  <% /Foreach %>
</ul>
''')
class Menu {
  String prefix;
  List<String> items;
}

// Example: fragments can nest
@View('''
<table>
  <% Foreach(rows) : Map<String, String> row %>
    <tr>
      <td>{{row['num']}}</td>
      <% Foreach(row['cols']) : String col %>
        <td>{{row['pref']}} - {{col}}</td>
      <% /Foreach %>
    </tr>
  <% /Foreach %>
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

// TODO: DI
// TODO: events
// TODO: property adapters
// TODO: imperative views
