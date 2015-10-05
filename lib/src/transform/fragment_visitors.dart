part of lambda.compiler;

/// Fragments can be nested. We are generating code for a specific [Fragment]
/// that's at the root of the current visitor.
abstract class RootTracker {
  Fragment _root = null;

  bool isRoot(Fragment fragment) {
    if (_root == null) _root = fragment;
    return _root == fragment;
  }
}

class FragmentBinder extends BaseBinder with RootTracker {

  FragmentBinder(String viewClassName) : super(viewClassName);

  @override
  bool visitFragment(Fragment node) {
    if (isRoot(node)) {
      return false;
    } else {
      return super.visitFragment(node);
    }
  }
}

class FragmentFieldGeneratorVisitor extends BaseFieldGeneratorVisitor
    with RootTracker {
  @override
  bool visitFragment(Fragment node) {
    if (isRoot(node)) {
      return false;
    } else {
      return super.visitFragment(node);
    }
  }
}

class FragmentBuildMethodVisitor extends BaseBuildMethodVisitor
    with RootTracker {

  @override
  bool visitFragment(Fragment node) {
    if (isRoot(node)) {
      _emit(' @override\n');
      _emit(' build() {');
      return false;
    } else {
      return super.visitFragment(node);
    }
  }

  @override
  void didVisitNode(AstNode node) {
    super.didVisitNode(node);
    if (node is Fragment && isRoot(node)) {
      _emit(' }');
    }
  }
}

class FragmentUpdateMethodVisitor extends BaseUpdateMethodVisitor
    with RootTracker {

  @override
  final Fragment currentFragment;

  FragmentUpdateMethodVisitor(this.currentFragment);

  @override
  bool visitFragment(Fragment node) {
    if (isRoot(node)) {
      _emit(' @override\n');
      _emit(' void update() {');
      _emit('   var _tmp;');
      return false;
    } else {
      return super.visitFragment(node);
    }
  }

  @override
  void didVisitNode(AstNode node) {
    super.didVisitNode(node);
    if (node is Fragment && isRoot(node)) {
      _emit(' endBuild(); }');
    }
  }
}
