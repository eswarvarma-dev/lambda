library lambda;

// Lambda aim to be a mix of React and Angular. Currently it uses uix as
// the reactive UI implementation.
import 'package:uix/uix.dart';
export 'package:uix/uix.dart';

/// A noop annotation that causes Dart analyzer to shut up about "unused"
/// imports. Because Lambda template language can refer to symbols, it requires
/// that those symbols are imported.
class LambdaUi {
  const LambdaUi({List uses});
}

/// Describes the UI structure of a component using Angular-ish template
/// language.
class View {
  final String code;
  const View(this.code);
}

abstract class Widget<C> {

  C get context;

  /* VNode | List<VNode> */ build();
}

/// Building block of a UI.
///
/// [C] is the type of the [context] object.
abstract class LambdaComponent<C> extends Component implements Widget {

  C context;

  @override
  updateView() {
    updateRoot(vRoot()(build()));
  }

  /* VNode | List<VNode> */ build();

  List<VNode> renderFragment(FragmentController fragmentController,
      Fragment fragmentFactory(), dynamic input) {
    fragmentController.render(input).map((item) {
      final fragment = fragmentFactory()
        ..context = this.context
        ..data = data;
      return fragment.build();
    }).toList();
  }
}

/// Used within the `<% ... %>` template blocks. Controls the creation of
/// fragments of templates enclosed within the fragment block by converting
/// an input value into a [List] of items, each corresponding to an instance
/// of a template fragment.
abstract class FragmentController<C, T, E> {

  final C context;

  FragmentController(this.context);

  List<E> render(T input);
}

abstract class Fragment<C, T> implements Widget {

  C context;
  Fragment parent;
  T data;

  VNode build();

  List<VNode> renderFragment(FragmentController fragmentController,
      Fragment fragmentFactory(), dynamic input) {
    fragmentController.render(input).map((item) {
      final fragment = fragmentFactory()
        ..context = this.context
        ..parent = this
        ..data = data;
      return fragment.build();
    }).toList();
  }
}

abstract class Decorator<C> {
  C context;
}
