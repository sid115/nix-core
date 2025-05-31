# Nix Speedrun

This section will cover some Nix language basics as fast as possible.

## Comments

```nix
# This is a comment

/*
  This is a block comment
*/
```

## Data types

Every value in Nix has a type. Some basic types are:

```nix
16 # integer

3.14 # float

false # boolean

"Hello, world!" # string

''
  This is also a string,
  but over multiple lines!
''
```

Assign a value to a variable:

```nix
myVar = "99";
```

And then inject it into a string:

```nix
''
  I got ${myVar} problems,
  but Nix ain't one.
''
```

Nix also has compound values. This is a list:

```nix
[ 123 "hello" true null [ 1 2 ] ]
```

You can mix different types in a list. This is an attribute set:

```nix
{
  foo = 4.56;
  bar = {
    baz = "this";
    qux = false;
  };
}
```

An attribute set is like an object. It is a collection of name-value-pairs called *attributes*. The expression above is equivalent to:

```nix
{
  foo = 4.56;
  bar.baz = "this";
  bar.qux = false;
}
```

## Evaluation

In Nix, everything is an expression that evaluates to a value. Create a `hello.nix`-file with the following content:

```nix
"Hello, world!"
```

Then, evaluate the file:

```bash
nix eval --file hello.nix
```

```
Hello, world!
```

A let-expression allows you to define local variables for an expression:

```nix
let
  alice = {
    name = "Alice";
    age = "26";
  };
in
''
  Her name is ${alice.name}.
  She is ${alice.age} years old.
''
```

## Functions

Functions have the following form:

```nix
pattern: body
```

The pattern specifies what the argument of the function must look like, and binds variables in the body to (parts of) the argument.

```nix
let
  increment = num: num + 1;
in
increment 49
```

Functions can only have a single argument. For multiple arguments, nest functions:

```nix
let
  isAllowedToDrive =
    name: age:
    if age >= 18 then "${name} is eligible to drive." else "${name} is too young to drive yet.";
in
isAllowedToDrive "Charlie" 19
```

It is common to pass multiple arguments in an attribute set instead. Since Nix is lazily evaluated, you can define multiple bindings in the same let-statement.

```nix
let
  add = { a, b }: a + b;
  result = add { a = 34; b = 35; };
in
result
```

You can also set optional arguments by providing default values:

```nix
let
  greet = { greeting ? "Hello", name }: "${greeting}, ${name}!";
in
greet { name = "Bob"; }
```

Let's look at one last example:

```nix
let
  myFunc = { a, b, c }: a + b * c;

  numbers = {
    a = 1;
    b = 2;
    c = 3;
  };

  result = myFunc { a = numbers.a; b = numbers.b; c = numbers.c; };
in
result
```

Nix provides some syntactical sugar to simplify that function call. The `with` keyword brings all attributes from an attribute set into the scope:

```nix
# ...
  result = with numbers; myFunc { a = a; b = b; c = c; };
# ...
```

However, this syntax is discouraged. Use `inherit` instead to explicitly list attributes to bring into the scope:

```nix
# ...
  inherit (numbers) a b c;
  result = myFunc { inherit a b c; };
# ...
```

## Builtin functions

Nix provides [builtin functions](https://nix.dev/manual/nix/2.25/language/builtins) by default through the global `builtins` constant. For example, `builtins.attrNames` gives you a list of all attributes of the given attribute set:

```nix
builtins.attrNames { a = 1; b = 2; }
# => [ "a" "b" ]
```

> Yes, this means that attribute keys, though defined as variables, are available as strings.

Some builtins are so common that the `builtins` prefix can be omitted. `map` is a builtin function that applies a function to each element of a list.

```nix
# squares.nix
let
  numbers = [ 5 2 1 4 3 ];
  squares = map (n: n * n) numbers;
in
{
  inherit numbers squares;
}
```

The `import` function allows to separate the codebase into multiple files:

```nix
# sort.nix
let
  results = import ./squares.nix; # paths have their own type
  inherit (results) squares;
  inherit (builtins) sort lessThan;
in
sort lessThan squares
```

> The `sort` function can be found in the [Nix manual](https://nix.dev/manual/nix/2.25/language/builtins#builtins-sort).
