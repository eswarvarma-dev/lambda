part of lambda.tree;

class Text extends Node {

  final String _value;

  Text(int typeIndex, String value) : super(typeIndex), _value = value;

  String get value => _value;

  @override
  ReplacementPatch diff(int selfIndex, Node other) {
    if (other is Text && other._value == _value) {
      return null;
    }
    return new ReplacementPatch(selfIndex, other);
  }
}
