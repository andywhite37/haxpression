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

  public function testStringIsFloat() {
    Assert.isTrue(Value.stringIsFloat("0"));
    Assert.isTrue(Value.stringIsFloat("1"));
    Assert.isTrue(Value.stringIsFloat("1.0"));
    Assert.isTrue(Value.stringIsFloat("1e7"));
    Assert.isTrue(Value.stringIsFloat("1.0e7"));
    Assert.isTrue(Value.stringIsFloat("+1.0e7"));
    Assert.isTrue(Value.stringIsFloat("+1.0e-7"));
    Assert.isFalse(Value.stringIsFloat(""));
    Assert.isFalse(Value.stringIsFloat("test"));
    Assert.isFalse(Value.stringIsFloat("0123abc"));
    Assert.isFalse(Value.stringIsFloat("0123abc"));
  }

  public function testStringIsInt() {
    Assert.isTrue(Value.stringIsInt("0"));
    Assert.isTrue(Value.stringIsInt("1"));
    Assert.isTrue(Value.stringIsInt("123"));
    Assert.isFalse(Value.stringIsInt("0.0"));
    Assert.isFalse(Value.stringIsInt("1.3"));
    Assert.isFalse(Value.stringIsInt(""));
    Assert.isFalse(Value.stringIsInt("test"));
    Assert.isFalse(Value.stringIsInt("test123"));
    Assert.isFalse(Value.stringIsInt("123test"));
  }
}
