package haxpression;

import haxe.Json;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;
using haxpression.utils.Maps;

class ExpressionGroup {
  var variableMap : Map<String, ExpressionOrValue>;

  public function new(?variableMap : Map<String, ExpressionOrValue>) {
    this.variableMap = variableMap != null ? variableMap : new Map();
  }

  public function clone() : ExpressionGroup {
    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().clone();
    });
  }

  public function addVariable(variable : String, expressionOrValue : ExpressionOrValue) : ExpressionGroup {
    var result = clone();
    result.variableMap.set(variable, expressionOrValue);
    return result;
  }

  public function removeVariable(variable : String) : ExpressionGroup {
    var result = clone();
    result.variableMap.remove(variable);
    return result;
  }

  public function addValues(variables : Map<String, Value>) : ExpressionGroup {
    var result = clone();
    for (variable in variables.keys()) {
      if (result.variableMap.exists(variable)) {
        throw new Error('variable $variable is already defined in expression group');
      }
      result.variableMap.set(variable, variables[variable]);
    }
    return result;
  }

  public function substitute(variables : Map<String, ExpressionOrValue>) : ExpressionGroup {
    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().substitute(variables);
    });
  }

  public function simplify() : ExpressionGroup {
    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().simplify();
    });
  }

  public function canEvaluate() {
    return all(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().canEvaluate();
    });
  }

  public function evaluate(?variables : Map<String, Value>) : Map<String, Value> {
    var result = variables != null ? addValues(variables) : clone();

    // Loop and substitute variables with expressions and eventually values until
    // all expressions in the group can be evaluated from raw values
    while (!result.canEvaluate()) {
      var topLevelVariables = result.getVariables();

      for (topLevelVariable in topLevelVariables) {
        var topLevelExpression = result.getExpression(topLevelVariable);

        if (topLevelExpression.canEvaluate()) {
          continue;
        }

        var topLevelExpressionVariables = topLevelExpression.getVariables();

        if (!topLevelVariables.containsAll(topLevelExpressionVariables)) {
          throw new Error('cannot evaluate expression group with undefined variables');
        }

        for (topLevelExpressionVariable in topLevelExpressionVariables) {
          // Replace the variable in the top-level expression with the expression defined
          // in the group for this variable
          topLevelExpression = topLevelExpression.substitute([
            topLevelExpressionVariable => result.getExpression(topLevelExpressionVariable)
          ]);
          result = result.addVariable(topLevelVariable, topLevelExpression);
        }
      }
    }

    return result.reduce(function(acc : Map<String, Value>, variable, expressionOrValue) {
      acc.set(variable, expressionOrValue.toExpression().evaluate(variables).toDynamic());
      return acc;
    }, new Map());
  }

  public function getVariables(?includeExpressions : Bool = false) : Array<String> {
    var variables = variableMap.keys().toArray().reduce(function(acc : Array<String>, variable : String) : Array<String> {
      if (!acc.contains(variable)) {
        acc.push(variable);
      }
      if (includeExpressions) {
        var expressionOrValue = variableMap[variable];
        for (expressionVariable in expressionOrValue.toExpression().getVariables()) {
          if (!acc.contains(expressionVariable)) {
            acc.push(expressionVariable);
          }
        }
      }
      return acc;
    }, []);

    variables.sort(function(a, b) {
      a = a.toLowerCase();
      b = b.toLowerCase();
      return if (a > b) 1;
        else if (a < b) -1;
        else 0;
    });

    return variables;
  }

  public function getExpressionOrValue(variable : String) : ExpressionOrValue {
    if (!variableMap.exists(variable)) {
      throw new Error('variable $variable is not defined in this expression group');
    }
    return variableMap[variable];
  }

  public function getExpression(variable : String) : Expression {
    return getExpressionOrValue(variable).toExpression();
  }

  public function getValue(variable : String) : Value {
    return getExpressionOrValue(variable).toValue();
  }

  public function toObject() : {} {
    return cast reduce(function(acc : {}, variable, expressionOrValue) : {} {
      Reflect.setField(acc, variable, expressionOrValue.toExpression().toString());
      return acc;
    }, {});
  }

  public function toString() {
    return Json.stringify(toObject(), null, '  ');
  }

  function all(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, variableMap[variable]);
    });
  }

  function any(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, variableMap[variable]);
    });
  }

  function map(callback : String -> ExpressionOrValue -> ExpressionOrValue) : ExpressionGroup {
    var newVariableMap : Map<String, ExpressionOrValue> = new Map();
    for (variable in getVariables()) {
      newVariableMap.set(variable, callback(variable, variableMap[variable]));
    }
    return new ExpressionGroup(newVariableMap);
  }

  function reduce<T>(callback : T -> String -> ExpressionOrValue -> T, acc : T) : T {
    for (variable in getVariables()) {
      acc = callback(acc, variable, variableMap[variable]);
    }
    return acc;
  }
}
