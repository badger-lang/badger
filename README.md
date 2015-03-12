# Badger

Badger is an experimental programming language.

It can be compiled to multiple languages or can be interpreted by the reference interpreter.

## Links

- [Wiki](https://github.com/badger-lang/badger/wiki)
- [Compiler Demo](http://badger.directcode.org/compiler.html)

## Example:

```badger
greet(name) {
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
pub global activate -sgit git://github.com/badger-lang/badger.git
```

To run an example, run the following command:

```bash
badger example/greeting.badger
```

To compile to JavaScript, run the following command:

```bash
badger --compile=js example/greeting.badger > hello.js
```
