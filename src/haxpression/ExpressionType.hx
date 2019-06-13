package haxpression;

enum ExpressionType {
  ELiteral(value : ValueType);
  EIdentifier(name : String);
  EUnary(operant : String, operand : ExpressionType);
  EBinary(operant : String, left : ExpressionType, right : ExpressionType);
  ECall(callee : String, arguments : Array<ExpressionType>);
  EConditional(test : ExpressionType, consequent : ExpressionType, alternate : ExpressionType);
  EArray(items : Array<ExpressionType>);
  ECompound(items : Array<ExpressionType>);
}
