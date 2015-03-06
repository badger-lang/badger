# Badger

Badger is an experimental programming language.

It can be compiled to multiple languages or can be interpreted by the reference interpreter.

## Links

- [Wiki](https://github.com/DirectMyFile/badger/wiki)

## Features

- Method Calls
- Variables
- Immutable Variables
- Function Definitions
- While Statements
- If Then Else Statements
- For In Statements

## Links

- [Wiki]()


## Example:

```badger
func greet(name) {
  return "Hello $(name)"
}

let names = ["Kenneth", "Logan", "Sam", "Mike"]

for name in names {
  print(greet(name))
}
```

## Getting Started

To install the badger interpreter, run the following command:

```bash
pub global activate -sgit git://github.com/DirectMyFile/badger.git
```

To run an example, run the following command:

```bash
badger example/greeting.badger
```

## Reference Implementation

This repository contains a reference implementation of a Badger evaluator, compiler, and parser.

### Features

- Generate JSON from AST
- Generate AST from JSON
- JavaScript Compiler
- Compiler API
