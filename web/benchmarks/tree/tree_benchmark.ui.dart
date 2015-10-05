library lambda.benchmarks.tree_benchmark;

import 'dart:html';
import 'package:lambda/lambda.dart';
import 'package:lambda/if.dart';
import '../util.dart';

@LambdaUi(uses: const[If])

main() {
  int maxDepth = getIntParameter('depth');
  int count = 0;
  ViewNode app;
  lambdaDestroyDom() {
    app.context.initData = new TreeNode('', null, null);
    app.update();
  }
  lambdaCreateDom() {
    var values = count++ % 2 == 0
        ? ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*']
        : ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', '-'];
    app.context.initData = buildTree(maxDepth, values, 0);
    app.update();
  }
  noop() {}
  initLambda() {
    app = AppComponent.viewFactory()..build();
    bindAction('#ng2DestroyDom', lambdaDestroyDom);
    bindAction('#ng2CreateDom', lambdaCreateDom);
    bindAction(
        '#ng2UpdateDomProfile', profile(lambdaCreateDom, noop, 'ng2-update'));
    bindAction('#ng2CreateDomProfile',
        profile(lambdaCreateDom, lambdaDestroyDom, 'ng2-create'));
    document.querySelector('app').append(app.hostElement);
  }
  initLambda();
}

class TreeNode {
  final String value;
  final TreeNode left;
  final TreeNode right;
  final bool hasRight;
  final bool hasLeft;
  TreeNode(this.value, TreeNode left, TreeNode right) :
    this.left = left,
    this.hasLeft = left != null,
    this.right = right,
    this.hasRight = right != null;
}

buildTree(maxDepth, values, curDepth) {
  if (identical(maxDepth, curDepth)) return new TreeNode('', null, null);
  return new TreeNode(
      values[curDepth],
      buildTree(maxDepth, values, curDepth + 1),
      buildTree(maxDepth, values, curDepth + 1));
}

@View('''
<span>
  {{data.value}}
  {% If(data.hasRight) %}
    <span>
      <TreeComponent [data]="data.right" />
    </span>
  {% /If %}
  {% If(data.hasLeft) %}
    <span>
      <TreeComponent [data]="data.left" />
    </span>
  {% /If %}
</span>
''')
class TreeComponent {
  static ViewNode viewFactory() => null;

  TreeNode data;
}

@View('''<TreeComponent [data]="initData" />''')
class AppComponent {
  static ViewNode viewFactory() => null;

  TreeNode initData;

  AppComponent() {
    this.initData = new TreeNode('', null, null);
  }
}
