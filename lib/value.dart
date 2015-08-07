library lambda.value;

import 'package:lambda/lambda.dart';

typedef OnTextChange(String newText);

class Value extends Decorator {
  /// The `value` of the `input` element
  String text;
  /// Callback used to notify about `value` changes.
  OnTextChange onChange;

  Value();
}
