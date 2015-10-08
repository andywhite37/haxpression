package haxpression;

import utest.Assert;

class TestValue {
  public function new() {
  }

  public function testIsNumeric() {
    var value : Value = 1.23;
    Assert.same(true, value.isNumeric());
    Assert.same(1.23, value.toFloat());
    Assert.same(1, value.toInt());
  }
}
