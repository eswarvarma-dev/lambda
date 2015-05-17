library lambda.component;

import 'tree.dart' as tree;

class Uses {
  const Uses(List usages);
}

class View {
  final String code;
  const View(this.code);
}

typedef Component ComponentFactory<T>(T data);

abstract class Component {
  tree.Node render();
}

abstract class Behavior<T> {
  List<tree.Node> render(T value);
}

class Template {
  final int id;
  final String code;

  Template(this.id, this.code);
}

class TemplateRegistry {
  static Template get(String code) {
    return new Template(0, code);  // TODO
  }
}
