library lambda.foreach;

import 'package:lambda/lambda.dart';

class Foreach<E> extends FragmentModelController<dynamic, Iterable<E>, E> {
  @override
  List<E> render(Iterable<E> iterable) {
    return iterable is List ? iterable : iterable.toList();
  }
}
