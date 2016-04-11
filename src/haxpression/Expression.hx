package haxpression;

import haxpression.ExpressionType;
import haxpression.ValueType;
using StringTools;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;
using haxpression.utils.Strings;
using haxpression.ExpressionTypes;
using haxpression.Expressions;

abstract Expression(ExpressionType) {
  public function new(expressionType : ExpressionType) {
    this = expressionType;
  }

  @:from
  public static function fromExpressionType(expressionType : ExpressionType) {
    return new Expression(expressionType);
  }

  @:to
  public function toExpressionType() : ExpressionType {
    return this;
  }

  @:from
  public static function fromString(input : String) : Expression {
    return Parser.parse(input);
  }

  public static function fromStringLiteral(input : String) : Expression {
    return Literal(Value.fromString(input));
  }

  public static function fromInt(input : Int) : Expression {
    return Literal(Value.fromInt(input));
  }

  public static function fromFloat(input : Float) : Expression {
    return Literal(Value.fromFloat(input));
  }

  public static function fromBool(input : Bool) : Expression {
    return Literal(Value.fromBool(input));
  }

  public function toString() : String {
    return switch this {
      case Literal(value) : new Value(value).toString();
      case Identifier(name) : name;
      case Unary(operator, operand): '${operator}${getString(operand)}';
      case Binary(operator, left, right) : '(${getString(left)} $operator ${getString(right)})';
      case Call(callee, arguments): '${callee}(${getStringDelimited(arguments, ",")})';
      case Conditional(test, consequent, alternate) : '(${getString(test)} ? ${getString(consequent)} : ${getString(alternate)})';
      case Array(items): '[${getStringDelimited(items, ",")}]';
      case Compound(items): getStringDelimited(items, ";");
    };
  }

  public function toDynamic() : Dynamic {
    return switch this {
      case Literal(value) : new Value(value).toDynamic();
      case _ : toString();
    };
  }

  public function toObject() : {} {
    return switch this {
      case Literal(value) : {
        type: "Literal",
        value: new Value(value).toDynamic() // allow the value to be passed-through with no conversion
      };
      case Identifier(name) : {
        type: "Identifier",
        name: name
      };
      case Unary(operator, operand) : {
        type: "Unary",
        operator: operator,
        operand: (operand : Expression).toObject()
      };
      case Binary(operator, left, right) : {
        type: "Binary",
        operator: operator,
        left: (left : Expression).toObject(),
        right: (right : Expression).toObject()
      };
      case Call(callee, arguments): {
        type: "Call",
        callee: callee,
        arguments: arguments.toObject()
      };
      case Conditional(test, consequent, alternate): {
        type: "Conditional",
        test: (test : Expression).toObject(),
        consequent: (consequent : Expression).toObject(),
        alternate: (alternate : Expression).toObject()
      };
      case Array(items) : {
        type: "Array",
        items: items.toObject()
      };
      case Compound(items) : {
        type: "Compound",
        items: items.toObject()
      };
    };
  }

  public function hasVariables() : Bool {
    return getVariables().length > 0;
  }

  public function hasVariablesStartingWith(text : String) {
    return getVariables().any(function(variable) {
      return variable.startsWith(text);
    });
  }

  public function hasVariablesContaining(text : String) {
    return getVariables().any(function(variable) {
      return variable.contains(text);
    });
  }

  public function hasVariablesEndingWith(text : String) {
    return getVariables().any(function(variable) {
      return variable.endsWith(text);
    });
  }

  public function hasVariablesWithin(variables : Array<String>) : Bool {
    return getVariables().all(function(variable) {
      return variables.contains(variable);
    });
  }

  public function getVariables(?options : { ?sort: Bool }) : Array<String> {
    if (options == null) options = {};
    if (options.sort == null) options.sort = true;
    var variables = [];
    accumulateVariables(variables);
    if (options.sort) {
      variables.sort(function(a, b) {
        a = a.toLowerCase();
        b = b.toLowerCase();
        return if (a > b) 1;
          else if (a < b) -1;
          else 0;
      });
    }
    return variables;
  }

  public function clone() : Expression {
    if (!Config.useCloneForExpressions) {
      return this;
    }

    return switch this {
      case Literal(value) :
        Literal(value);
      case Identifier(name) :
        Identifier(name);
      case Unary(operator, operand) :
        Unary(operator, (operand : Expression).clone());
      case Binary(operator, left, right) :
        Binary(operator, (left : Expression).clone(), (right : Expression).clone());
      case Call(callee, arguments) :
        Call(callee, arguments.clone());
      case Conditional(test, consequent, alternate) :
        Conditional((test : Expression).clone(), (consequent : Expression).clone(), (alternate : Expression).clone());
      case Array(items) :
        Array(items.clone());
      case Compound(items) :
        Compound(items.clone());
    };
  }

  public function substitute(variables : Map<String, ExpressionOrValue>) : Expression {
    return switch this {
      case Literal(value):
        Literal(value);
      case Identifier(name):
        variables.exists(name) ? variables.get(name).toExpression() : Identifier(name);
      case Unary(operator, expression):
        Unary(operator, (expression : Expression).substitute(variables));
      case Binary(operator, left, right):
        Binary(operator, (left : Expression).substitute(variables), (right : Expression).substitute(variables));
      case Call(callee, arguments):
        Call(callee, arguments.substitute(variables));
      case Conditional(test, consequent, alternate):
        Conditional((test : Expression).substitute(variables), (consequent : Expression).substitute(variables), (alternate : Expression).substitute(variables));
      case Array(items):
        Array(items.substitute(variables));
      case Compound(items):
        Array(items.substitute(variables));
    };
  }

  public function simplify() : Expression {
    return switch this {
      case Literal(value):
        Literal(value);
      case Identifier(name):
        Identifier(name);
      case Unary(operator, operand):
        if ((operand : Expression).canEvaluate()) {
          Literal(UnaryOperations.evaluate(operator, (operand : Expression).evaluate()));
        } else {
          Unary(operator, (operand : Expression).simplify().toExpressionType());
        }
      case Binary(operator, left, right):
        if ((left : Expression).canEvaluate() && (right : Expression).canEvaluate()) {
          Literal(BinaryOperations.evaluate(operator, (left : Expression).evaluate(), (right : Expression).evaluate()));
        } else {
          Binary(operator, (left : Expression).simplify(), (right : Expression).simplify());
        }
      case Conditional(test, consequent, alternate):
        if ((test : Expression).canEvaluate()) {
          (test : Expression).evaluate() ?
            (consequent : Expression).simplify() :
            (alternate : Expression).simplify();
        } else {
          Conditional((test : Expression).simplify(), (consequent : Expression).simplify(), (alternate : Expression).simplify());
        }
      case Call(callee, arguments):
        if (arguments.canEvaluateAll()) {
          return Literal(CallOperations.evaluate(callee, arguments.evaluate()));
        } else {
          Call(callee, arguments.simplify());
        }
      case Array(items):
        Array(items.simplify());
      case Compound(items):
        Compound(items.simplify());
    };
  }

  public function canEvaluate() : Bool {
    return switch this {
      case Literal(value):
        true;
      case Identifier(name):
        false;
      case Unary(operator, operand):
        (operand : Expression).canEvaluate();
      case Binary(operator, left, right):
        (left : Expression).canEvaluate() && (right : Expression).canEvaluate();
      case Call(callee, arguments):
        CallOperations.canEvaluate(callee, arguments);
      case Conditional(test, consequent, alternate):
        if (!(test : Expression).canEvaluate()) {
          false;
        } else {
          (test : Expression).evaluate() ?
            (consequent : Expression).canEvaluate() :
            (alternate : Expression).canEvaluate();
        }
      case Array(items):
        items.canEvaluateAll();
      case Compound(items):
        items.canEvaluateAll();
    };
  }

  public function evaluate(?variables : Map<String, Value>) : Value {
    if (variables == null) variables = new Map();

    return switch this {
      case Literal(value) :
        value;
      case Identifier(name):
        if (!variables.exists(name)) {
          throw new Error('cannot evaluate expression with unset variable: $name');
        }
        variables.get(name);
      case Unary(operator, operand):
        var operandValue = (operand : Expression).evaluate(variables);
        UnaryOperations.evaluate(operator, operandValue);
      case Binary(operator, left, right):
        var leftValue = (left : Expression).evaluate(variables);
        var rightValue = (right : Expression).evaluate(variables);
        BinaryOperations.evaluate(operator, leftValue, rightValue);
      case Call(callee, arguments):
        CallOperations.evaluate(callee, arguments.evaluate(variables));
      case Conditional(test, consequent, alternate):
        (test : Expression).evaluate(variables).toBool() ?
          (consequent : Expression).evaluate(variables) :
          (alternate : Expression).evaluate(variables);
      case Array(items):
        // We'll just assume the value of an array expression is the last value
        // or none if there are no items in the array
        if (items.length == 0) VNA;
        else {
          var values = items.evaluate(variables);
          values[values.length - 1];
        }
      case Compound(items):
        // We'll just assume the value of an compound expression is the last value
        // or none if there are no items in the array
        if (items.length == 0) VNA;
        else {
          var values = items.evaluate(variables);
          values[values.length - 1];
        }
    };
  }

  public function isLiteral(?value : Value) : Bool {
    return switch [toExpressionType(), value.toValueType()] {
      case [Literal(VInt(a)), VInt(b)] : a == b;
      case [Literal(VFloat(a)), VFloat(b)] : a == b;
      case [Literal(VString(a)), VString(b)] : a == b;
      case [Literal(VBool(a)), VBool(b)] : a == b;
      case _: false;
    };
  }

  public function isIdentifier(?name : String) : Bool {
    return switch toExpressionType() {
      case Identifier(n) : name != null ? name == n : true;
      case _: false;
    };
  }

  public function isCompound() : Bool {
    return switch toExpressionType() {
      case Compound(_) : true;
      case _: false;
    };
  }

  function accumulateVariables(variables : Array<String>) : Void {
    switch this {
      case Literal(value) :
        // no-op - no variables to accumulate here
      case Identifier(name) :
        // Push a variable if we haven't seen it already
        if (variables.indexOf(name) == -1) variables.push(name);
      case Unary(operator, operand):
        (operand : Expression).accumulateVariables(variables);
      case Binary(operator, left, right):
        (left : Expression).accumulateVariables(variables);
        (right : Expression).accumulateVariables(variables);
      case Call(callee, arguments):
        arguments.each(function(expression) (expression : Expression).accumulateVariables(variables));
      case Conditional(test, consequent, alternate):
        (test : Expression).accumulateVariables(variables);
        (consequent : Expression).accumulateVariables(variables);
        (alternate : Expression).accumulateVariables(variables);
      case Array(items):
        items.each(function(expression) (expression : Expression).accumulateVariables(variables));
      case Compound(items):
        items.each(function(expression) (expression : Expression).accumulateVariables(variables));
    };
  }

  function getString(expressionType : ExpressionType) : String {
    return (expressionType : Expression).toString();
  }

  function getStringDelimited(expressionTypes : Array<ExpressionType>, delimiter : String) : String {
    delimiter = '${delimiter.trim()} ';
    return expressionTypes.map(getString).join(delimiter);
  }
}
