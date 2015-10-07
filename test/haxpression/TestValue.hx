package haxpression;

import utest.Assert;

class TestValue {
  public function new() {
  }

  public function testIsNumeric() {
    var value : Value = 1.23;
    Assert.same(true, value.isNumeric());
  }
}
