package haxpression;

enum ExpressionType {
  Literal(value : Value);
  Identifier(name : String);
  Unary(operator : String, operand : ExpressionType);
  Binary(operator : String, left : ExpressionType, right : ExpressionType);
  Call(callee : String, arguments : Array<ExpressionType>);
  Conditional(test : ExpressionType, consequent : ExpressionType, alternate : ExpressionType);
  Array(items : Array<ExpressionType>);
  Compound(items : Array<ExpressionType>);
}
