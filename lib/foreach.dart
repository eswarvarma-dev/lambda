library lambda.foreach;

import 'package:lambda/lambda.dart';

class Foreach<E> extends FragmentController<dynamic, Iterable<E>, E> {

  Foreach(context) : super(context);

  @override
  List<E> render(Iterable<E> iterable) {
    return iterable is List ? iterable : iterable.toList();
  }
}
