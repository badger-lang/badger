# Badger

Badger is an experimental programming language.

## Example:

```badger
func greet(name) {
  return "Hello $(name)"
}

let names = ["Kenneth", "Logan", "Sam"]

for name in names {
  print(greet(name))
}
```

## Features

- Method Calls
- Variables
- Immutable Variables
- Function Definitions
- While Statements
- If Then Else Statements
- For In Statements

## Reference Implementation

This repository contains a reference implementation of a Badger evaluator, compiler, and parser.

### Features

- Generate JSON from AST
- Generate AST from JSON
- JavaScript Compiler
- Compiler API
