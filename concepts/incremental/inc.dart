library lambda.incremental;

abstract class Component {
  void createUi();

  open(String tag) {
  }

  close() {
  }

  text(String value) {
  }
}

class View {
  final String template;
  const View(this.template);
}
