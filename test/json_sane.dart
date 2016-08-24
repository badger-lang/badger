import "package:badger/parser.dart";

final Map<String, dynamic> PROG = {
  "declarations": [],
  "statements": [
    {
      "type": "if",
      "condition": {"type": "boolean literal", "value": false},
      "block": [
        {
          "type": "expression statement",
          "expression": {
            "type": "method call",
            "reference": "print",
            "args": [
              {
                "type": "string literal",
                "components": ["This Badger Environment is not sane!"]
              }
            ]
          }
        }
      ],
      "else": [
        {
          "type": "expression statement",
          "expression": {
            "type": "method call",
            "reference": "print",
            "args": [
              {
                "type": "string literal",
                "components": ["This Badger Environment is sane!"]
              }
            ]
          }
        }
      ]
    }
  ]
};

main() async {
  var builder = new BadgerJsonParser();
  var prog = builder.build(PROG);
  print(new BadgerPrinter(prog).print());
}
