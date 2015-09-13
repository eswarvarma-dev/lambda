library app.ui;

import 'package:lambda/lambda.dart';
import 'package:lambda/foreach.dart';

@LambdaUi(uses: const [Foreach])
part 'app.gen.dart'; // generated part

// Component: reusable & composable piece of interactive DOM
@View('<div class="button">{{title}}</div>')
class Button {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  String title;
}

// Example: composition
@View('''
<form>
  <Button [title]="_actionName" />
</form>
''')
class Form {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  String _actionName;
}

// Fragments: control UI structure
@View('''
<ul>
  {% Foreach(items) : String item %}
    <li>{{prefix}} - {{item}}</li>
  {% /Foreach %}
</ul>
''')
class Menu {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  String prefix;
  List<String> items;
}

// Example: fragments can nest
@View('''
<table>
  {% Foreach(rows) : Map<String, String> row %}
    <tr>
      <td>{{row['num']}}</td>
      {% Foreach(row['cols']) : String col %}
        <td>{{row['pref']}} - {{col}}</td>
      {% /Foreach %}
    </tr>
  {% /Foreach %}
</table>
''')
class Table {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  List<Map<String, dynamic>> rows = [
    { 'num' : 1, 'pref' : 'a', 'cols' : [ 'foo', 'bar', 'baz' ]},
    { 'num' : 2, 'pref' : 'b', 'cols' : [ 'qux', 'quux', 'cruft' ]},
  ];
}

// Decorators: control element properties
@View('''
<div>
  [[ Value(text: text, onChange: textChanged) ]]
  <input type="text">
</div>
''')
class MaterialInput {
  // This is implemented by transformer
  static LambdaView viewFactory() => null;

  String text;

  textChanged(String newText) {

  }
}

// TODO: DI
// TODO: events
// TODO: property adapters
// TODO: imperative views
