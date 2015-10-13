package haxpression;

using haxpression.utils.Arrays;
using haxpression.utils.Iterators;
using haxpression.utils.Maps;

class ExpressionGroup {
  var map : Map<String, ExpressionOrValue>;

  public function new(?map : Map<String, ExpressionOrValue>) {
    this.map = map != null ? map : new Map();
  }

  public function clone() : ExpressionGroup {
    return _map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().clone();
    });
  }

  public function substitute(variables : Map<String, ExpressionOrValue>) : ExpressionGroup {
    return _map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().substitute(variables);
    });
  }

  public function simplify() : ExpressionGroup {
    return _map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().simplify();
    });
  }

  public function evaluate(?variables : Map<String, ExpressionOrValue>) : Map<String, Value> {
    // 1. substitute primitive value variables in all expressions in this group
    var newExpressionGroup = variables != null ? substitute(variables) : clone();

    var canEvaluateAll = false;
    while (!canEvaluateAll) {
      canEvaluateAll = newExpressionGroup._all(function(variable, expressionOrValue) {
        return expressionOrValue.toExpression().canEvaluate();
      });

      if (canEvaluateAll) {
        break;
      }

      for (key in map.keys()) {
      }
    }

    return null;
  }

  public function getVariables(?includeExpressions : Bool = false) : Array<String> {
    var variables = _reduce(function(variable, expressionOrValue, acc : Array<String>) : Array<String> {
      if (!acc.contains(variable)) {
        acc.push(variable);
      }
      if (includeExpressions) {
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
    if (!map.exists(variable)) {
      throw new Error('variable $variable is not defined in this expression group');
    }
    return map[variable];
  }

  public function getExpression(variable : String) : Expression {
    return getExpressionOrValue(variable).toExpression();
  }

  public function getValue(variable : String) : Value {
    return getExpressionOrValue(variable).toValue();
  }

  function _all(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, map[variable]);
    });
  }

  function _any(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, map[variable]);
    });
  }

  function _map(callback : String -> ExpressionOrValue -> ExpressionOrValue) : ExpressionGroup {
    var newMap : Map<String, ExpressionOrValue> = new Map();
    for (variable in getVariables()) {
      newMap.set(variable, callback(variable, map[variable]));
    }
    return new ExpressionGroup(newMap);
  }

  function _reduce<T>(callback : String -> ExpressionOrValue -> T -> T, acc : T) : T {
    for (variable in getVariables()) {
      acc = callback(variable, map[variable], acc);
    }
    return acc;
  }
}
