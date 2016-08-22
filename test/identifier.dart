import "package:petitparser/petitparser.dart";

void main() {
  var p = pattern("A-Za-z_\$\u03A0").plus();
  print(p.parse("int").value);
}
