library lambda.html_syncer;

import 'dart:html' as dom;
import 'tree.dart' as tree;

class HtmlSyncer {
  final dom.Element _host;

  HtmlSyncer.adopt(this._host);

  // TODO: implement diffing and patching
  void sync(tree.Node rootNode) {
    _host.childNodes.clear();
    _syncInto(rootNode, _host);
  }

  _syncInto(tree.Node node, dom.Element destination) {
    if (node is tree.Text) {
      destination.appendText(node.value);
    } else if (node is tree.Element) {
      tree.Element el = node;
      dom.Element child = _createDomElementFor(el);
      destination.append(child);
      for (int i = 0; i < el.length; i++) {
        _syncInto(el[i], child);
      }
    }
  }

  dom.Element _createDomElementFor(tree.Element el) {
    var domEl = new dom.Element.tag(el.tagName);
    el.attributes.forEach((String name, String value) {
      domEl.setAttribute(name, value);
    });
    return domEl;
  }
}
