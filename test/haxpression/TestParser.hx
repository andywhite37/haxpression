package haxpression;

import utest.Assert;
import haxpression.ExpressionType;
using haxpression.AssertExpressionString;

class TestParser {
  public function new() {
  }

  public function testSpaces() {
    "2+3".evaluatesToInt(5);
    "2+3".evaluatesToInt(5);
    "2+ 3".evaluatesToInt(5);
    "2 +3".evaluatesToInt(5);
    " 2+3".evaluatesToInt(5);
    "2+3 ".evaluatesToInt(5);
    "2 + 3".evaluatesToInt(5);
    " 2 + 3".evaluatesToInt(5);
    " 2 + 3 ".evaluatesToInt(5);
    " 2 + 3 ".evaluatesToInt(5);
    "2  +  3".evaluatesToInt(5);
    " 2  +  3 ".evaluatesToInt(5);
  }

  public function testBasicNumbers() {
    switch Parser.parse("1").toExpressionType() {
      case Literal(value) : Assert.same(1, value.toInt());
      case _ : Assert.fail();
    };
    switch Parser.parse("-1").toExpressionType() {
      case Unary(operator, operand) : Assert.same("-", operator); Assert.same(1, (operand : Expression).evaluate().toFloat());
      case _ : Assert.fail();
    };
    switch Parser.parse("1.23").toExpressionType() {
      case Literal(value) : Assert.same(1.23, value.toFloat());
      case _ : Assert.fail();
    };
    switch Parser.parse("-1.23").toExpressionType() {
      case Unary(operator, operand) : Assert.same("-", operator); Assert.same(1.23, (operand : Expression).evaluate().toFloat());
      case _ : Assert.fail();
    };
  }

  public function testLiteral() {
    "true".evaluatesToBool(true);
    "1".evaluatesToInt(1);
    "-1".evaluatesToInt(-1);
  }

  public function testBinaryLogical() {
    "true || false".evaluatesToTrue();
    "false || true".evaluatesToTrue();
    "true || true".evaluatesToTrue();
    "false || false".evaluatesToFalse();
    "true && false".evaluatesToFalse();
    "false && true".evaluatesToFalse();
    "true && true".evaluatesToTrue();
    "false && false".evaluatesToFalse();

    // Note: && has higher precedence than ||
    "true && true || true".evaluatesToTrue();
    "false && true || true".evaluatesToTrue();
    "true && false || true".evaluatesToTrue();
    "false && false || true".evaluatesToTrue();

    "true && true || false".evaluatesToTrue();
    "false && true || false".evaluatesToFalse();
    "true && false || false".evaluatesToFalse();
    "false && false || false".evaluatesToFalse();

    "true || true && true".evaluatesToTrue();
    "false || true && true".evaluatesToTrue();
    "true || false && true".evaluatesToTrue();
    "false || false && true".evaluatesToFalse();

    "true || true && false".evaluatesToTrue();
    "false || true && false".evaluatesToFalse();
    "true || false && false".evaluatesToTrue();
    "false || false && false".evaluatesToFalse();
  }

  public function testBinaryAddition() {
    "2 + 3".evaluatesToInt(2 + 3);
    "3 + 4.7".evaluatesToFloat(3 + 4.7);
    "2 + 3 + 4.7".evaluatesToFloat(2 + 3 + 4.7);
  }

  public function testBinarySubtraction() {
    "2 - 3".evaluatesToInt(2 - 3);
    "3 - 4.7".evaluatesToFloat(3 - 4.7);
    "2 - 3 - 4.7".evaluatesToFloat(2 - 3 - 4.7);
  }

  public function testBinaryAdditionAndSubtraction() {
    "2 - 3 + 4.7".evaluatesToFloat(2 - 3 + 4.7);
    "2 + 3 - 4.7".evaluatesToFloat(2 + 3 - 4.7);
  }

  public function testBinaryMultiplication() {
    '2 * 3'.evaluatesToInt(2 * 3);
    '2 * 4.7'.evaluatesToFloat(2 * 4.7);
    '2 * 4.7 * 3'.evaluatesToFloat(2 * 4.7 * 3);
  }

  public function testBinaryDivision() {
    '2 / 3'.evaluatesToFloat(2 / 3);
    '2 / 4.7'.evaluatesToFloat(2 / 4.7);
    '2 / 4.7 / 3'.evaluatesToFloat(2 / 4.7 / 3);
  }

  public function testBinaryMultiplicationAndDivison() {
    '2 * 4.7 / 3'.evaluatesToFloat(2 * 4.7 / 3);
    '2 / 4.7 * 3'.evaluatesToFloat(2 / 4.7 * 3);
  }

  public function testWithVariables() {
    var result1 : Float = ('PI * pow(r, 2)' : Expression).evaluate([
      "PI" => Math.PI,
      "r" => 10
    ]);
    Assert.same(Math.PI * Math.pow(10, 2), result1);
  }

  public function testIdentifier() {
    Assert.isTrue(("MYVAR" : Expression).isIdentifier("MYVAR"));
    Assert.isTrue(("NS!VAR" : Expression).isIdentifier("NS!VAR"));
    Assert.isTrue(("NS!VAR:TWO" : Expression).isIdentifier("NS!VAR:TWO"));
    Assert.isTrue(("$NS_START!VAR:TWO" : Expression).isIdentifier("$NS_START!VAR:TWO"));
  }

  public function testToString(){
    '1 + 2'.toStringSameAs('(1 + 2)');
    '1 + 2 + 3'.toStringSameAs('((1 + 2) + 3)');
    '1 + 2 + 3 + 4'.toStringSameAs('(((1 + 2) + 3) + 4)');
    '1 + 2 * 3 + 4'.toStringSameAs('((1 + (2 * 3)) + 4)');
    '1 * 2 + 3 * 4'.toStringSameAs('((1 * 2) + (3 * 4))');
    '1 * PI + MY_VAR * 4'.toStringSameAs('((1 * PI) + (MY_VAR * 4))');
  }

  public function testToObject() {
    '1 + 2'.toObjectSameAs({
      type: "Binary",
      operator: "+",
      left: {
        type: "Literal",
        value: 1
      },
      right: {
        type: "Literal",
        value: 2
      }
    });

    '1 + 2 + 3'.toObjectSameAs({
      type: "Binary",
      operator: "+",
      left: {
        type: "Binary",
        operator: "+",
        left: {
          type: "Literal",
          value: 1
        },
        right: {
          type: "Literal",
          value: 2
        }
      },
      right: {
        type: "Literal",
        value: 3
      }
    });

    '1 + 2 + 3 + 4'.toObjectSameAs({
      type: "Binary",
      operator: "+",
      left: {
        type: "Binary",
        operator: "+",
        left: {
          type: "Binary",
          operator: "+",
          left: {
            type: "Literal",
            value: 1
          },
          right: {
            type: "Literal",
            value: 2
          }
        },
        right: {
          type: "Literal",
          value: 3
        },
      },
      right: {
        type: "Literal",
        value: 4
      }
    });
  }

}
