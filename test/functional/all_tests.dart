library lambda.functional.tests;

import 'basic_component.ui_test.dart' as basic_component;
import 'events.ui_test.dart' as events;
import 'fragments.ui_test.dart' as fragments;
import 'decorators.ui_test.dart' as decorators;

main() {
  basic_component.main();
  fragments.main();
  events.main();
  decorators.main();
}
