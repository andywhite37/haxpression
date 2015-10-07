package haxpression;

import utest.Assert;
import haxpression.ExpressionType;

class TestExpression {
  public function new() {
  }

  public function testToString() {
    var expression : Expression = Binary("+", Literal(1), Literal(2));
    Assert.same('(1 + 2)', expression.toString());
  }
}
