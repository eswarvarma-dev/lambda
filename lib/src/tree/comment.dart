part of lambda.tree;

class Comment extends Node {

  final String _value;

  Comment(int typeIndex, String value) : super(typeIndex), _value = value;

  String get value => _value;

  @override
  ReplacementPatch diff(int selfIndex, Node other) {
    if (other is Comment && other._value == _value) {
      return null;
    }
    return new ReplacementPatch(selfIndex, other);
  }
}
