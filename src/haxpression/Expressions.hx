package haxpression;

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

  public static function evaluate(expressions : Array<Expression>, ?variables : Array<{ name: String, value: Value }>) : Array<Value> {
    return expressions.map(function(expression) {
      return expression.evaluate(variables);
    });
  }
}
