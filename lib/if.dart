library lambda.if_;

import 'package:lambda/lambda.dart';

class If extends FragmentModelController<dynamic, bool, dynamic> {

  static const _SHOW = const [true];
  static const _HIDE = const [];

  @override
  List render(bool condition) {
    return condition ? _SHOW : _HIDE;
  }
}
