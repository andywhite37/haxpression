package haxpression;

import haxpression.ExpressionType;
using Lambda;
using StringTools;

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

  @:to
  public function toString() : String {
    return switch this {
      case Literal(value) : value.toString();
      case Identifier(name) : name;
      case Unary(operator, argument): '${operator}${getString(argument)}';
      case Binary(operator, left, right) : '(${getString(left)} $operator ${getString(right)})';
      case Call(callee, arguments): '${callee}(${getStringDelimited(arguments, ",")})';
      case Conditional(test, consequent, alternate) : '(${getString(test)} ? ${getString(consequent)} : ${getString(alternate)})';
      case Array(items): '[${getStringDelimited(items, ",")}]';
      case Compound(expressions): getStringDelimited(expressions, ";");
    };
  }

  public function toObject() : { } {
    return switch this {
      case Literal(value) : {
        type: "Literal",
        value: value.toDynamic()
      };
      case Identifier(name) : {
        type: "Identifier",
        name: name
      };
      case Unary(operator, expression) : {
        type: "Unary",
        operator: operator,
        argument: (expression : Expression).toObject()
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
        arguments: arguments.map(function(argument) {
          return (argument : Expression).toObject();
        })
      };
      case Conditional(test, consequent, alternate): {
        type: "Conditional",
        test: (test : Expression).toObject(),
        consequent: (consequent : Expression).toObject(),
        alternate: (alternate : Expression).toObject()
      };
      case Array(items) : {
        type: "Array",
        items: items.map(function(item) {
          return (item : Expression).toObject();
        })
      };
      case Compound(expressions) : {
        type: "Compound",
        expressions: expressions.map(function(expression) {
          return (expression : Expression).toObject();
        })
      }
    };
  }

  public function hasVariables() : Bool {
    return getVariables().length > 0;
  }

  public function getVariables() : Array<String> {
    var variables = [];
    accumulateVariables(variables);
    variables.sort(function(a, b) {
      a = a.toLowerCase();
      b = b.toLowerCase();
      return if (a > b) 1;
        else if (a < b) -1;
        else 0;
    });
    return variables;
  }

  function accumulateVariables(variables : Array<String>) : Void {
    switch this {
      case Literal(value) :
        // no-op
      case Identifier(name) :
        if (variables.indexOf(name) == -1) variables.push(name);
      case Unary(operator, expression):
        (expression : Expression).accumulateVariables(variables);
      case Binary(operator, left, right):
        (left : Expression).accumulateVariables(variables);
        (right : Expression).accumulateVariables(variables);
      case Call(callee, arguments):
        arguments.iter(function(expression) (expression : Expression).accumulateVariables(variables));
      case Conditional(test, consequent, alternate):
        (test : Expression).accumulateVariables(variables);
        (consequent : Expression).accumulateVariables(variables);
        (alternate : Expression).accumulateVariables(variables);
      case Array(items):
        items.iter(function(expression) (expression : Expression).accumulateVariables(variables));
      case Compound(expressions):
        expressions.iter(function(expression) (expression : Expression).accumulateVariables(variables));
    };
  }

  public function clone() : Expression {
    return switch this {
      case Literal(value) :
        Literal(value);
      case Identifier(name) :
        Identifier(name);
      case Unary(operator, expression) :
        Unary(operator, (expression : Expression).clone());
      case Binary(operator, left, right) :
        Binary(operator, (left : Expression).clone(), (right : Expression).clone());
      case Call(callee, arguments) :
        Call(callee, arguments.map(function(expression) return (expression : Expression).clone().toExpressionType()));
      case Conditional(test, consequent, alternate) :
        Conditional((test : Expression).clone(), (consequent : Expression).clone(), (alternate : Expression).clone());
      case Array(items) :
        Array(items.map(function(expression) return (expression : Expression).clone().toExpressionType()));
      case Compound(expressions) :
        Compound(expressions.map(function(expression) return (expression : Expression).clone().toExpressionType()));
    };
  }

  public function substituteExpression(name : String, expression : Expression) : Expression {
    var newExpression = (this : Expression).clone();
    return newExpression;
  }

  public function substituteValue(name : String, value : Value) : Expression {
    return switch this {
      case Literal(value) :
        Literal(value);
      case Identifier(iname) :
        if (name == iname) {
          Literal(value);
        } else {
          Identifier(iname);
        }
      case Unary(operator, expression):
        Unary(operator, (expression : Expression).substituteValue(name, value));
      case Binary(operator, left, right):
        Binary(operator, (left : Expression).substituteValue(name, value), (right : Expression).substituteValue(name, value));
      case Call(callee, arguments):
        Call(callee, arguments.map(function(argument) return (argument : Expression).substituteValue(name, value).toExpressionType()));
      case Conditional(test, consequent, alternate):
        Conditional((test : Expression).substituteValue(name, value), (consequent : Expression).substituteValue(name, value), (alternate : Expression).substituteValue(name, value));
      case Array(items):
        Array(items.map(function(item) return (item : Expression).substituteValue(name, value).toExpressionType()));
      case Compound(expressions):
        Array(expressions.map(function(expression) return (expression : Expression).substituteValue(name, value).toExpressionType()));
    };
  }

  public function substituteExpressions(variables : Array<{ name : String, expression : Expression }>) : Expression {
    var newExpression = (this : Expression).clone();
    variables.iter(function(variable) {
      newExpression = substituteExpression(variable.name, variable.expression);
    });
    return newExpression;
  }

  public function substituteValues(variables : Array<{ name : String, value : Value }>) : Expression {
    var newExpression = (this : Expression).clone();
    variables.iter(function(variable) {
      newExpression = substituteValue(variable.name, variable.value);
    });
    return newExpression;
  }

  public function evaluate(?variables : Array<{ name : String, value : Value }>) : Value {
    var newExpression = variables != null ? substituteValues(variables) : clone();

    return switch newExpression.toExpressionType() {
      case Literal(value) : value;
      case Identifier(name): throw new Error('cannot evaluate with unset variable $name');
      case Unary(operator, argument):
        var argumentValue = (argument : Expression).evaluate(variables);
        UnaryOperations.evaluate(operator, argumentValue);
      case Binary(operator, left, right):
        var leftValue = (left : Expression).evaluate(variables);
        var rightValue = (right : Expression).evaluate(variables);
        BinaryOperations.evaluate(operator, leftValue, rightValue);
      case Call(callee, arguments):
        throw new Error('cannot evaluate Call expression');
      case Conditional(test, consequent, alternate):
        (test : Expression).evaluate(variables).toBool() ?
          (consequent : Expression).evaluate(variables) :
          (alternate : Expression).evaluate(variables);
      case Array(items):
        throw new Error('cannot evaluate Array expression');
      case Compound(expression):
        throw new Error('cannot evaluate Compound expression');
    };
  }

  public function isCompound() : Bool {
    return switch toExpressionType() {
      case Compound(_) : true;
      case _: false;
    };
  }

  function getString(expressionType : ExpressionType) : String {
    return fromExpressionType(expressionType).toString();
  }

  function getStringDelimited(expressionTypes : Array<ExpressionType>, delimiter : String) : String {
    delimiter = '${delimiter.trim()} ';
    return expressionTypes.map(function(expressionType) getString(expressionType)).join(delimiter);
  }
}
