library app.ui;

import 'inc.dart';

part 'app.gen.dart'; // generated part

// Component: reusable & composable piece of interactive DOM
@View('''<div [id]="id" class="button">{{title}}</div>''')
class Button {
  String id;
  String title;
}

// Example: composition
class Form extends Component {
  String _actionName;

  createUi() => '''
    <form>
      <Button [title]="_actionName" />
    </form>
  ''';
}

// Fragments: control UI structure
class Menu extends Component {
  String prefix;
  List<String> items;

  createUi() => '''
    <ul>
      % for (item in items) {
        <li>{{prefix}} - {{item}}</li>
      % }
    </ul>
  ''';
}

// Example: fragments can nest
class Table extends Component {
  List<Map<String, dynamic>> rows = [
    { 'num' : 1, 'pref' : 'a', 'cols' : [ 'foo', 'bar', 'baz' ]},
    { 'num' : 2, 'pref' : 'b', 'cols' : [ 'qux', 'quux', 'cruft' ]},
  ];

  createUi() => '''
    <table>
      % for (var row in rows) {
        <tr>
          <td>{{row['num']}}</td>
          % for (col in row['cols']) {
            <td>{{row['pref']}} - {{col}}</td>
          % }
        </tr>
      % }
    </table>
  ''';
}

// Decorators: control element properties
class MaterialInput {
  var currentTheme;

  createUi() => '''
    <div>
      % @Material(theme: currentTheme)
      <input type="text">
    </div>
  ''';
}

// TODO: DI
// TODO: events
// TODO: property adapters - decorators?
// TODO: imperative views
// TODO: child queries
// TODO: locals
