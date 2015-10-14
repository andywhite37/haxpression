package haxpression;

import haxe.Json;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;
using haxpression.utils.Maps;

class ExpressionGroup {
  var map : Map<String, ExpressionOrValue>;

  public function new(?map : Map<String, ExpressionOrValue>) {
    this.map = map != null ? map : new Map();
  }

  public function clone() : ExpressionGroup {
    return mapVariables(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().clone();
    });
  }

  public function set(variable : String, expressionOrValue : ExpressionOrValue) : ExpressionGroup {
    var result = clone();
    result.map.set(variable, expressionOrValue);
    return result;
  }

  public function add(variables : Map<String, Value>) : ExpressionGroup {
    var result = clone();
    for (variable in variables.keys()) {
      if (result.map.exists(variable)) {
        throw new Error('variable $variable is already defined in expression group');
      }
      result.map.set(variable, variables[variable]);
    }
    return result;
  }

  public function substitute(variables : Map<String, ExpressionOrValue>) : ExpressionGroup {
    return mapVariables(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().substitute(variables);
    });
  }

  public function simplify() : ExpressionGroup {
    return mapVariables(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().simplify();
    });
  }

  public function evaluate(?variables : Map<String, Value>) : Map<String, Value> {
    // 1. substitute primitive value variables in all expressions in this group
    var result = variables != null ? add(variables) : clone();

    var canEvaluateAll = false;
    while (!canEvaluateAll) {
      //trace("-------------------------------------");
      //trace(result);

      canEvaluateAll = result.allVariables(function(variable, expressionOrValue) {
        return expressionOrValue.toExpression().canEvaluate();
      });

      //trace('canEvaluateAll: $canEvaluateAll');

      if (canEvaluateAll) {
        break;
      }

      var topLevelVariables = result.getVariables();

      //trace('topLevelVariables: $topLevelVariables');

      for (targetVariable in topLevelVariables) {
        var targetExpression = result.getExpression(targetVariable);
        //trace('targetVariable: $targetVariable => $targetExpression');

        // If we can evaluate this variable, we are done
        if (targetExpression.canEvaluate()) {
          //trace('$targetVariable can be evaluated!');
          continue;
        }

        // Loop over the other top-level variables, and see if we can replace any in the target
        var targetExpressionVariables = targetExpression.getVariables();
        //trace('$targetVariable variables: $targetExpressionVariables');

        if (!topLevelVariables.containsAll(targetExpressionVariables)) {
          throw new Error('cannot evaluate expression group with undefined variables');
        }

        for (targetExpressionVariable in targetExpressionVariables) {
          //trace('before substitute $targetVariable -> $targetExpressionVariable');
          //trace(result);

          targetExpression = targetExpression.substitute([
            targetExpressionVariable => result.getExpression(targetExpressionVariable)
          ]);

          result = result.set(targetVariable, targetExpression);

          //trace('after substitute $targetVariable -> $targetExpressionVariable');
          //trace(result);
        }
      }
    }

    return result.reduceVariables(function(variable, expressionOrValue, acc : Map<String, Value>) {
      acc.set(variable, expressionOrValue.toExpression().evaluate(variables).toDynamic());
      return acc;
    }, new Map());
  }

  public function getVariables(?includeExpressions : Bool = false) : Array<String> {
    var variables = map.keys().toArray().reduce(function(variable, acc : Array<String>) : Array<String> {
      if (!acc.contains(variable)) {
        acc.push(variable);
      }
      if (includeExpressions) {
        var expressionOrValue = map[variable];
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

  public function toObject() : {} {
    return cast reduceVariables(function(variable, expressionOrValue, acc : Dynamic) : Dynamic {
      Reflect.setField(acc, variable, expressionOrValue.toExpression().toString());
      return acc;
    }, {});
  }

  public function toString() {
    return Json.stringify(toObject(), null, '  ');
  }

  function allVariables(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, map[variable]);
    });
  }

  function anyVaraibles(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, map[variable]);
    });
  }

  function mapVariables(callback : String -> ExpressionOrValue -> ExpressionOrValue) : ExpressionGroup {
    var newMap : Map<String, ExpressionOrValue> = new Map();
    for (variable in getVariables()) {
      newMap.set(variable, callback(variable, map[variable]));
    }
    return new ExpressionGroup(newMap);
  }

  function reduceVariables<T>(callback : String -> ExpressionOrValue -> T -> T, acc : T) : T {
    for (variable in getVariables()) {
      acc = callback(variable, map[variable], acc);
    }
    return acc;
  }
}
