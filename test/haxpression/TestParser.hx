package haxpression;

import utest.Assert;
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

  public function testLogical() {
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

  public function testAddition() {
    "2 + 3".evaluatesToInt(2 + 3);
    "3 + 4.7".evaluatesToFloat(3 + 4.7);
    "2 + 3 + 4.7".evaluatesToFloat(2 + 3 + 4.7);
  }

  public function testSubtraction() {
    "2 - 3".evaluatesToInt(2 - 3);
    "3 - 4.7".evaluatesToFloat(3 - 4.7);
    "2 - 3 - 4.7".evaluatesToFloat(2 - 3 - 4.7);
  }

  public function testAdditionAndSubtraction() {
    "2 - 3 + 4.7".evaluatesToFloat(2 - 3 + 4.7);
    "2 + 3 - 4.7".evaluatesToFloat(2 + 3 - 4.7);
  }

  public function testMultiplication() {
    '2 * 3'.evaluatesToInt(2 * 3);
    '2 * 4.7'.evaluatesToFloat(2 * 4.7);
    '2 * 4.7 * 3'.evaluatesToFloat(2 * 4.7 * 3);
  }

  public function testDivision() {
    '2 / 3'.evaluatesToFloat(2 / 3);
    '2 / 4.7'.evaluatesToFloat(2 / 4.7);
    '2 / 4.7 / 3'.evaluatesToFloat(2 / 4.7 / 3);
  }

  public function testMultiplicationAndDivison() {
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

  public function testWithExpressionSubstitutions() {
    var mappings : Map<String, Expression> = [
      "MAP_VALUE_1" => "2 * SOURCE_1 + 0.5 * SOURCE_2",
      "MAP_VALUE_2" => "4 * SOURCE_1 + 10 * SOURCE_3",
      "MAP_VALUE_3" => "2 * SOURCE_1 + 0.3 * MAP_VALUE_2"
    ];
    //var hasMapVariables = true;
    //while (hasMapVariables) {
    //}
    //for (key in mappings.keys()) {
    //}
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
