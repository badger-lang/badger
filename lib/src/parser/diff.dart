part of badger.parser;

class BadgerDiffer {
  final Program left;
  final Program right;

  BadgerDiffer(this.left, this.right);

  bool hasDifference() {
    return !getDiffNode().hasNothing;
  }

  DiffNode getDiffNode() {
    if (_node != null) {
      return _node;
    }

    var simplifier = new BadgerSimplifier();
    var a = new BadgerJsonBuilder(simplifier.modifyProgram(left)).build();
    var b = new BadgerJsonBuilder(simplifier.modifyProgram(right)).build();
    var differ = new JsonDiffer(JSON.encode(a), JSON.encode(b));
    _node = differ.diff();

    return _node;
  }

  DiffNode _node;
}
