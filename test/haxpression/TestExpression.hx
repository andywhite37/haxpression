package haxpression;

import utest.Assert;
import haxpression.ExpressionType;
using haxpression.AssertExpression;

class TestExpression {
  public function new() {
  }

  public function testToString() {
    (Binary("+", Literal(1), Literal(2)) : Expression).toStringSameAs("(1 + 2)");
    (Binary("+", Binary("+", Literal(1), Literal(2)), Literal(3)) : Expression).toStringSameAs("((1 + 2) + 3)");
  }
}
