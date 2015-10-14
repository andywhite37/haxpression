# haxpression

Basic math expression parser and evaluator for Haxe

## Description

This library parses basic math expressions into an expression-tree, and
provides methods to replace variables with values or other expressions,
simplify expressios, and evaluate expressions.

## Credits

The expression parser logic was ported from this JavaScript library:
[jsep](http://jsep.from.so/).

## Examples

### Basic expression parsing and evaluation

```haxe
// parse an expression string into an expression tree (Expression)
var expr = Parser.parse('1 + x / y');

// same as:
var expr : Expression = '1 + x / y';

trace(expr);
// prints: (1 + (x / y))

trace(expr.toObject());
// prints:
// {
//   "type": "Binary",
//   "operator": "+",
//   "left: {
//     type: "Literal",
//     value: 1
//   },
//   "right": {
//     "type": "Binary",
//     "operator": "/",
//     "left": {
//       "type": "Identifier",
//       "name": "x"
//     },
//     "right": {
//       "type": "Identifier",
//       "name": "y"
//     }
//   }
// }

trace(expr.getVariables());
// prints: ["x", "y"]

// evaluate with variable values:
var result : Float = expr.evaluate([
  "x" => 5,
  "y" => 10
]);

trace(result);
// prints 1.5
```

### Expression group parsing and evaluation

An "expression group" consists of a set of named expressions, which can
consist of variables defined both internally and externally to the
group.  The group can be evaluated by providing all of the external variable
values, and by resolving the interal variable references.  There cannot
be any circular references between variables/expressions.

```haxe
var group = new ExpressionGroup([
  'MAP_1' => '2 * SOURCE_1 + 3 * SOURCE_2', // external variables
  'MAP_2' => '0.5 * SOURCE_1 + 10 * MAP_1', // external and internal variables
  'MAP_3' => '0.2 * MAP_1 + 0.3 * MAP_2', // internal variables
]);

var result = group.evaluate([
  'SOURCE_1' => 2.34,
  'SOURCE_2' => 3.14
]);

trace(result);
// prints:
// {
//   MAP_1 => 14.1,
//   MAP_2 => 142.17,
//   MAP_3 => 45.471,
//   SOURCE_1 => 2.34,
//   SOURCE_2 => 3.14,
// }
```

### Customizable binary/unary/function operations

haxpression provides default binary, unary, and function operations
out-of-the-box, including most of the common math operators and
`Math` functions.

Binary, unary, and function call operations can be customized using the
`BinaryOperations`, `UnaryOperations`, and `CallOperations` classes.

```
// Use built-in + binary operator and abs function
var result : Int = ('1 + abs(x)' : Expression).evaluate([ "x" => -5 ]);
trace(result);
// prints: 6

// Create new binary operator and function
CallOperations.add("myfunc", 2, function(arguments) return arguments[0].toFloat() + arguments[1].toFloat()); // 2 is the function arity
BinaryOperations.add("&&&", 10, function(left, right) return left.toFloat() / right.toFloat()); // 10 is the operator precedence - see BinaryOperations

var resultFloat : Float = ('myfunc(x, 10) &&& myfunc(y, 20)' : Expression).evaluate([ "x" => 2, "y" => 3 ]);
trace(resultFloat);
// prints: 0.5217391304347826 = (2 + 10) / (3 + 20)
```
