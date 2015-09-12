library lambda.if_;

import 'package:lambda/lambda.dart';

typedef ViewNode IfFragmentFactory();

class If extends FragmentController<bool, IfFragmentFactory> {

  bool _lastCondition = false;

  If(IfFragmentFactory f) : super(f);

  void render(bool condition) {
    // users should provide reasonable non-null defaults
    assert(condition != null);
    if (condition != _lastCondition) {
      if (condition) {
        ViewNode fragment = fragmentFactory()
          ..context = context
          ..build();
        this.insert(0, fragment);
      } else {
        this.remove(0);
      }
      _lastCondition = condition;
    }
    updateFragments();
  }
}
