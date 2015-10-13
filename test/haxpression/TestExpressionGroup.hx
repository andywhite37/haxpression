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
    var map1 = 2 * source1 + 3 * source2;
    var map2 = 0.5 * source1 + 10 * map1;
    var map3 = 0.2 * map1 + 0.3 * map2;

    var result = expressionGroup.evaluate([
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
    ]);

    Assert.same([
      'SOURCE_1' => source1,
      'SOURCE_2' => source2,
      'MAP_1' => map1,
      'MAP_2' => map2,
      'MAP_3' => map3,
    ], result);
  }

  public function testValidate() {
    // TODO: check for cycles
    Assert.pass();
  }
}
