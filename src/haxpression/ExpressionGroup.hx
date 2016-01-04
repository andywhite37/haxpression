package haxpression;

import graphx.Graph;
import graphx.NodeOrValue;
import graphx.StringGraph;
import haxpression.utils.Strings;
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
    if (!Config.useCloneForExpressionGroups) {
      return this;
    }

    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().clone();
    });
  }

  public function hasVariable(variable : String) : Bool {
    return variableMap.exists(variable);
  }

  public function getVariables(?includeExpressionVariables : Bool = false) : Array<String> {
    var variables = variableMap.keys().toArray().reduce(function(variables : Array<String>, variable) {
      if (!variables.contains(variable)) {
        variables.push(variable);
      }
      if (includeExpressionVariables) {
        var expression = getExpression(variable);
        for (expressionVariable in expression.getVariables()) {
          if (!variables.contains(expressionVariable)) {
            variables.push(expressionVariable);
          }
        }
      }
      return variables;
    }, []);
    variables.sort(Strings.icompare);
    return variables;
  }

  public function getExpressionOrValue(variable : String) : ExpressionOrValue {
    if (!hasVariable(variable)) {
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

  public function setVariable(variable : String, expressionOrValue : ExpressionOrValue) : ExpressionGroup {
    var result = clone();
    result.variableMap.set(variable, expressionOrValue);
    return result;
  }

  public function setVariables(expressionOrValueMap : Map<String, ExpressionOrValue>) : ExpressionGroup {
    var expressionGroup = clone();
    for (variable in expressionOrValueMap.keys()) {
      if (expressionGroup.hasVariable(variable)) {
        throw new Error('variable $variable is already defined in expression group');
      }
      expressionGroup.variableMap.set(variable, expressionOrValueMap[variable]);
    }
    return expressionGroup;
  }

  public function setVariableValues(valueMap : Map<String, Value>) : ExpressionGroup {
    var expressionOrValueMap = valueMap.mapValues(function(key, value) {
      return ExpressionOrValue.fromValue(value);
    }, new Map());
    return setVariables(expressionOrValueMap);
  }

  public function removeVariable(variable : String) : ExpressionGroup {
    var expressionGroup = clone();
    expressionGroup.variableMap.remove(variable);
    return expressionGroup;
  }

  public function substitute(expressionOrValueMap : Map<String, ExpressionOrValue>) : ExpressionGroup {
    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().substitute(expressionOrValueMap);
    });
  }

  public function simplify() : ExpressionGroup {
    return map(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().simplify();
    });
  }

  public function canExpand() : Bool {
    var topLevelVariables = getVariables();
    if (topLevelVariables.isEmpty()) return false;
    return any(function(variable, expressionOrValue) {
      var expressionVariables = expressionOrValue.toExpression().getVariables();
      return expressionVariables.isEmpty() ? false : topLevelVariables.containsAny(expressionVariables);
    });
  }

  public function expand() : ExpressionGroup {
    return time('expand', function() return getDependencySortedVariables().reduce(function(expressionGroup : ExpressionGroup, topLevelVariable) {
      if (expressionGroup.hasVariable(topLevelVariable)) {
        var expression = expressionGroup.getExpression(topLevelVariable);
        return expressionGroup.expandExpressionForVariable(topLevelVariable);
      }
      return expressionGroup;
    }, this));
  }

  public function expandExpressionForVariable(variable : String) : ExpressionGroup {
    return time('expandExpressionForVariable $variable', function() {
      var expression = getExpression(variable);
      var expressionVariables = expression.getVariables();
      expression = expressionVariables.reduce(function(expression : Expression, expressionVariable) {
        if (hasVariable(expressionVariable)) {
          expression = expression.substitute([
            expressionVariable => getExpression(expressionVariable)
          ]);
        }
        return expression;
      }, expression);
      return setVariable(variable, expression);
    });
  }

  public function canEvaluate() : Bool {
    return all(function(variable, expressionOrValue) {
      return expressionOrValue.toExpression().canEvaluate();
    });
  }

  public function evaluate(?valueMap : Map<String, Value>) : Map<String, Value> {
    var expressionGroup = valueMap != null ? setVariableValues(valueMap) : clone();
    return getDependencySortedVariables().reduce(function(expressionGroup : ExpressionGroup, topLevelVariable) {
      expressionGroup = expressionGroup.expandExpressionForVariable(topLevelVariable);
      return expressionGroup.evaluateExpressionForVariable(topLevelVariable);
    }, expressionGroup).toValueMap();
  }

  public function evaluateExpressionForVariable(variable : String) : ExpressionGroup {
    var expression = getExpression(variable);
    if (!expression.canEvaluate()) {
      var variables = expression.getVariables();
      throw new Error('cannot evaluate expression group variable: $variable with unset variables ${variables.join(", ")} (expression: $expression)');
    }
    var value = expression.evaluate();
    return setVariable(variable, value);
  }

  public function toValueMap() : Map<String, Value> {
    return getVariables().reduce(function(map : Map<String, Value>, variable) {
      map.set(variable, getValue(variable));
      return map;
    }, new Map());
  }

  public function toObject() : {} {
    return cast reduce(function(acc : {}, variable, expressionOrValue) : {} {
      Reflect.setField(acc, variable, expressionOrValue.toDynamic());
      return acc;
    }, {});
  }

  public function toString() {
    return Json.stringify(toObject(), null, '  ');
  }

  public function all(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().all(function(variable) {
      return callback(variable, variableMap[variable]);
    });
  }

  public function any(callback : String -> ExpressionOrValue -> Bool) : Bool {
    return getVariables().any(function(variable) {
      return callback(variable, variableMap[variable]);
    });
  }

  public function map(callback : String -> ExpressionOrValue -> ExpressionOrValue) : ExpressionGroup {
    var newExpressionOrValueMap : Map<String, ExpressionOrValue> = new Map();
    for (variable in getVariables()) {
      newExpressionOrValueMap.set(variable, callback(variable, variableMap[variable]));
    }
    return new ExpressionGroup(newExpressionOrValueMap);
  }

  public function reduce<T>(callback : T -> String -> ExpressionOrValue -> T, acc : T) : T {
    for (variable in getVariables()) {
      acc = callback(acc, variable, variableMap[variable]);
    }
    return acc;
  }

  public function getVariableDependencyGraph() : Graph<String> {
    return time('getVariableDependencyGraph', function() return getVariables().reduce(function(graph : Graph<String>, variable) {
      var expression = getExpression(variable);
      var expressionVariables = expression.getVariables();
      return expressionVariables.length > 0 ?
        graph.addEdgesTo(variable, NodeOrValue.mapValues(expressionVariables)) :
        graph;
    }, new StringGraph()));
  }

  public function getDependencySortedVariables() : Array<String> {
    return time('getDependencySortedVariables', function() return getVariableDependencyGraph().topologicalSort());
  }

  public function time<T>(description : String, callback : Void -> T) : T {
    /*
    var startTime = Date.now().getTime();
    var result = callback();
    var endTime = Date.now().getTime();
    var durationMillis = endTime - startTime;
    trace('$description took $durationMillis ms');
    return result;
    */
    return callback();
  }
}
