library lambda.directives;

import 'package:lambda/lambda.dart';

class For<T> extends Behavior<Iterable<T>> {
  final ComponentFactory<T> _factory;

  For(this._factory);

  @override
  List<Node> render(Iterable<T> iter) {
    return iter.map((T data) => _factory(data).render()).toList();
  }
}

class If extends Behavior<bool> {
  final ComponentFactory<bool> _factory;

  If(this._factory);

  @override
  List<Node> render(bool condition) {
    return condition
    ? [_factory(condition)]
    : null;
  }
}
