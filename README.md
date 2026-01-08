# Forth Interpreter in Ruby

This is a simple Forth-style interpreter implemented in Ruby.

## Features

- **Data Stack**: Common Forth-style data stack for operations.
- **Dictionary**: Extendable dictionary with built-in words and user-defined words.
- **RPN Syntax**: Reverse Polish Notation for arithmetic and stack manipulation.
- **Arithmetic**: Basic operations (`+`, `-`, `*`, `/`).
- **Stack Manipulation**: `DUP`, `DROP`, `SWAP`, `OVER`.
- **Comparison Operators**: `=`, `<`, `>`.
- **Conditional Branching**: `IF`, `ELSE`, `THEN` structures.
- **Dictionary Extensions**: Colon definitions `: name ... ;`.
- **Variables**: `VARIABLE`, `@` (fetch), `!` (store).

## Usage

```ruby
require_relative 'lib/forth'

forth = Forth.new

# Basic Arithmetic
forth.execute("1 2 +")
puts forth.stack.last # => 3

# Define a new word
forth.execute(": square dup * ;")
forth.execute("5 square")
puts forth.stack.last # => 25

# Conditionals
forth.execute("10 20 < if 100 else 200 then")
puts forth.stack.last # => 100

# Variables
forth.execute("variable myvar")
forth.execute("42 myvar !")
forth.execute("myvar @")
puts forth.stack.last # => 42
```

## Running Tests

To run the tests, make sure you have RSpec installed:

```bash
rspec spec/forth_spec.rb
```
