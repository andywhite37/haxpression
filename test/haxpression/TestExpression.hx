package haxpression;

import utest.Assert;
import haxpression.ExpressionType;
using haxpression.AssertExpression;

class TestExpression {
  public function new() {
  }

  /*
  public function testForReadme() {
    trace("--------------");
    var expr = Parser.parse('1 + x / y');
    trace(expr);
    trace(expr.toObject());

    var result : Float = expr.evaluate([
      "x" => 5,
      "y" => 10
    ]);
    trace(result);

    trace("--------------");

    var result : Int = ('1 + abs(x)' : Expression).evaluate([ "x" => -5 ]);
    trace(result);

    trace("--------------");

    CallOperations.add("myfunc", 2, function(arguments) return arguments[0].toFloat() + arguments[1].toFloat());
    BinaryOperations.add("&&&", 10, function(left, right) return left.toFloat() / right.toFloat());

    var resultFloat : Float = ('myfunc(x, 10) &&& myfunc(y, 20)' : Expression).evaluate([ "x" => 2, "y" => 3 ]);
    trace(resultFloat);

    trace("--------------");
    Assert.pass();
  }
  */

  public function testToString() {
    (Binary("+", Literal(1), Literal(2)) : Expression).toStringSameAs("(1 + 2)");
    (Binary("+", Binary("+", Literal(1), Literal(2)), Literal(3)) : Expression).toStringSameAs("((1 + 2) + 3)");
  }

  public function testSubstituteValue() {
    var expr : Expression = Binary("+", Literal(1), Identifier("PI"));
    expr.substitute([ "PI" => Math.PI ]).evaluatesToFloat(1 + Math.PI);
  }

  public function testSubstituteExpression() {
    var expr : Expression = Binary("+", Literal(1), Identifier("PI"));
    expr = expr.substitute([ "PI" => '1 + 2 + 0.14' ]);
    expr.toStringSameAs('(1 + ((1 + 2) + 0.14))');
  }

  public function testSimplify() {
    ('1 + 2 + 2' : Expression).simplify().toStringSameAs('5');
    // TODO: this can be simplified more with deeper simplify logic
    ('1 + 2 + y + 4 + x' : Expression).simplify().toStringSameAs('(((3 + y) + 4) + x)');
  }
}
