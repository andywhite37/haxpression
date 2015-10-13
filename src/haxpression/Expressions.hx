package haxpression;

using haxpression.utils.Arrays;

/**
  Extension methods for Array<Expression>
  **/
class Expressions {
  public static function toExpressionTypes(expressions : Array<Expression>) : Array<ExpressionType> {
    return expressions.map(function(expression) {
      return expression.toExpressionType();
    });
  }

  public static function clone(expressions : Array<Expression>) : Array<Expression> {
    return expressions.map(function(expression) {
      return expression.clone();
    });
  }

  public static function evaluate(expressions : Array<Expression>, ?variables : Map<String, Value>) : Array<Value> {
    return expressions.map(function(expression) {
      return expression.evaluate(variables);
    });
  }

  public static function hasVariablesStartingWith(expressions : Array<Expression>, text : String) {
    return expressions.any(function(expression) {
      return expression.hasVariablesStartingWith(text);
    });
  }
}
