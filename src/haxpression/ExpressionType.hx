package haxpression;

enum ExpressionType<T> {
  Literal(value : T);
  Identifier(name : String);
  Unary(operator : String, operand : ExpressionType<T>);
  Binary(operator : String, left : ExpressionType<T>, right : ExpressionType<T>);
  Call(callee : String, arguments : Array<ExpressionType<T>>);
  Conditional(test : ExpressionType<T>, consequent : ExpressionType<T>, alternate : ExpressionType<T>);
  Array(items : Array<ExpressionType<T>>);
  Compound(items : Array<ExpressionType<T>>);
}
