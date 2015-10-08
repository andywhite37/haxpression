package haxpression;

class ExpressionTypes {
  public static function clone(expressionTypes : Array<ExpressionType>) : Array<ExpressionType> {
    return expressionTypes.map(function(expressionType) {
      return (expressionType : Expression).clone().toExpressionType();
    });
  }

  public static function evaluate(expressionTypes : Array<ExpressionType>, ?variables : Array<{ name : String, value: Value }>) : Array<Value> {
    return expressionTypes.map(function(expressionType) {
      return (expressionType : Expression).evaluate(variables);
    });
  }

  public static function substituteValue(expressionTypes : Array<ExpressionType>, name: String, value: Value) : Array<ExpressionType> {
    return expressionTypes.map(function(expressionType) {
      return (expressionType : Expression).substituteValue(name, value).toExpressionType();
    });
  }

  public static function substituteExpression(expressionTypes : Array<ExpressionType>, name: String, expression: Expression) : Array<ExpressionType> {
    return expressionTypes.map(function(expressionType) {
      return (expressionType : Expression).substituteExpression(name, expression).toExpressionType();
    });
  }

  public static function toObject(expressionTypes : Array<ExpressionType>) : Array<{}> {
    return expressionTypes.map(function(expressionType) {
      return (expressionType : Expression).toObject();
    });
  }
}

