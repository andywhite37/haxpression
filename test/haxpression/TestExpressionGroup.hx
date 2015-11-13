package haxpression;

import utest.Assert;

class TestExpressionGroup {
  public function new() {
  }

  public function testEvaluate() {
    var expressionGroup = new ExpressionGroup([
      'MAP_1' => '2 * SOURCE_1 + 3 * SOURCE_2',
      'MAP_2' => '0.5 * SOURCE_1 + 10 * MAP_1',
      'MAP_3' => '0.2 * MAP_1 + 0.3 * MAP_2',
    ]);

    var source1 = 2.34;
    var source2 = 3.14;

    var result = expressionGroup.evaluate([
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
    ]);

    var expectedMap1 = 2 * source1 + 3 * source2;
    var expectedMap2 = 0.5 * source1 + 10 * expectedMap1;
    var expectedMap3 = 0.2 * expectedMap1 + 0.3 * expectedMap2;

    Assert.same([
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
      'MAP_1' => expectedMap1,
      'MAP_2' => expectedMap2,
      'MAP_3' => expectedMap3,
    ], result);

    //trace(result);
  }

  public function testCanExpand() {
    var group = new ExpressionGroup([
      'A' => 1,
      'B' => 2,
      'AB' => 'A * B'
    ]);
    Assert.isTrue(group.canExpand());
  }

  public function testExpand() {
    var expressionGroup = new ExpressionGroup([
      'A' => 1,
      'B' => 2,
      'C' => 3,
      'D' => 4,
      'A_PLUS_B' => 'A + B',
      'B_PLUS_C' => 'B + C',
      'C_PLUS_D' => 'C + D',
      'X_PLUS_Y' => 'X + Y',
      'A_PLUS_B_PLUS_X' => 'A_PLUS_B + X'
    ]);

    Assert.isTrue(expressionGroup.canExpand());
    var result = expressionGroup.expand();
    Assert.same({
      A: 1,
      A_PLUS_B: '(1 + 2)',
      A_PLUS_B_PLUS_X: '((1 + 2) + X)',
      B: 2,
      B_PLUS_C: '(2 + 3)',
      C: 3,
      C_PLUS_D: '(3 + 4)',
      D: 4,
      X_PLUS_Y: '(X + Y)',
    }, result.toObject());

    var simplified = result.simplify();
    Assert.same({
      A: 1,
      A_PLUS_B: 3,
      A_PLUS_B_PLUS_X: '(3 + X)',
      B: 2,
      B_PLUS_C: 5,
      C: 3,
      C_PLUS_D: 7,
      D: 4,
      X_PLUS_Y: '(X + Y)',
    }, simplified.toObject());
  }

  public function testExpand2() {
    var group = new ExpressionGroup([
      'dfs!SALES$0' => 'CapIQ!IQ_REV + IFNA0(CapIQ!IQ_OTHER_REV)',
      'dfs!SALES$1' => 'CapIQ!IQ_TOTAL_REV',
      'dfs!SALES' => 'COALESCE(dfs!SALES$0,dfs!SALES$1)'
    ]);
    group = group.expand();
    Assert.same('COALESCE((CapIQ!IQ_REV + IFNA0(CapIQ!IQ_OTHER_REV)), CapIQ!IQ_TOTAL_REV)', group.getExpression('dfs!SALES').toString());
  }

  public function testValidate() {
    // TODO: check for cycles
    Assert.pass();
  }
}
