package haxpression;

import utest.Assert;
import haxpression.ValueType;

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

  public function testFromString() {
    switch Value.fromString('123').toValueType() {
      case VInt(x) : Assert.equals(123, x);
      case _ : Assert.fail();
    };

    switch Value.fromString('123.45').toValueType() {
      case VFloat(x) : Assert.equals(123.45, x);
      case _ : Assert.fail();
    };

    switch Value.fromString('true').toValueType() {
      case VBool(x) : Assert.equals(true, x);
      case _ : Assert.fail();
    };

    switch Value.fromString('hi').toValueType() {
      case VString(x) : Assert.equals('hi', x);
      case _ : Assert.fail();
    };

    switch Value.fromString('NA').toValueType() {
      case VNA : Assert.pass();
      case _ : Assert.fail();
    };

    switch Value.fromString('na').toValueType() {
      case VNA : Assert.pass();
      case _ : Assert.fail();
    };

    switch Value.fromString('NM').toValueType() {
      case VNM : Assert.pass();
      case _ : Assert.fail();
    };

    switch Value.fromString('nm').toValueType() {
      case VNM : Assert.pass();
      case _ : Assert.fail();
    };
  }

  public function testToString() {
    Assert.same('123', Value.fromInt(123).toString());
    Assert.same('123.45', Value.fromFloat(123.45).toString());
    Assert.same('true', Value.fromBool(true).toString());
    Assert.same('test', Value.fromString('test').toString());
    Assert.same('NA', Value.na().toString());
    Assert.same('NM', Value.nm().toString());
  }
}
