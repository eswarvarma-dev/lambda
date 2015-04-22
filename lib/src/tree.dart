/**
 * Implementation of immutable virtual tree.
 */
library lambda.tree;

import 'package:built_collection/built_collection.dart';

final _NO_CHILDREN = new BuiltList<Node>();
final _NO_ATTRS = new BuiltMap<String, String>();

abstract class Node {
  String toXml();
}

class Element extends Node {
  final String tagName;
  final BuiltList<Node> _children;
  final BuiltMap<String, String> _attributes;

  Element(this.tagName, {
    BuiltList<Node> children,
    BuiltMap<String, String> attributes
  }) : this._children = children != null ? children : _NO_CHILDREN,
       this._attributes = attributes != null ? attributes : _NO_ATTRS;

  BuiltList<Node> get children => _children;

  Node operator[](int index) {
    return _children[index];
  }

  int get length => _children.length;

  bool get hasAttributes =>
    _attributes != null &&
    _attributes.isNotEmpty;

  BuiltMap<String, String> get attributes {
    return _attributes;
  }

  bool get hasChildren =>
    _children != null &&
    _children.isNotEmpty;

  @override
  String toXml() {
    final sb = new StringBuffer('<');
    sb.write(tagName);

    if (hasAttributes) {
      attributes.forEach((String name, String value) {
        sb
          ..write(' ')
          ..write(name)
          ..write('="')
          ..write(value)
          ..write('"');
      });
    }

    sb.write('>');

    if (hasChildren) {
      this._children
        .map((Node child) => child.toXml())
        .forEach(sb.write);
    }

    sb
      ..write('</')
      ..write(tagName)
      ..write('>');
    return sb.toString();
  }

  @override
  String toString() => toXml();

  Element queryById(String id) {
    if (this.attributes['id'] == id) {
      return this;
    } else if (hasChildren) {
      for (int i = 0; i < _children.length; i++) {
        if (_children[i] is! Element) continue;
        Element childElem = _children[i];
        Element childResult = childElem.queryById(id);
        if (childResult != null) {
          return childResult;
        }
      }
    }
    return null;
  }
}

class Text extends Node {

  final String _value;

  Text(String value) : _value = value;

  String get value => _value;

  @override
  String toXml() => _value;

  @override
  String toString() => 'TEXT($value)';
}

Element div(Iterable<Node> children) {
  return new Element('div', children: new BuiltList<Node>(children));
}

Text text(String value) => new Text(value);
