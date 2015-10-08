package haxpression;

import utest.Assert;

class AssertExpression {
  public static function evaluatesToTrue(expression : Expression) : Void {
    evaluatesToBool(expression, true);
  }

  public static function evaluatesToFalse(expression : Expression) : Void {
    evaluatesToBool(expression, false);
  }

  public static function evaluatesToBool(expression : Expression, expected : Bool) : Void {
    var actual : Bool = expression.evaluate();
    Assert.same(expected, actual);
  }

  public static function evaluatesToInt(expression : Expression, expected : Int) : Void {
    var actual : Int = expression.evaluate();
    Assert.same(expected, actual);
  }

  public static function evaluatesToFloat(expression : Expression, expected : Float) : Void {
    var actual : Float = expression.evaluate();
    Assert.same(expected, actual);
  }

  public static function evaluatesToString(expression : Expression, expected : String) : Void {
    var actual : String = expression.evaluate();
    Assert.same(expected, actual);
  }

  public static function evaluatesToNone(expression : Expression) : Void {
    var actual = expression.evaluate();
    Assert.isTrue(actual.isNone());
  }

  public static function toObjectSameAs(expression : Expression, expected : {}) {
    var actual = expression.toObject();
    Assert.same(expected, actual);
  }

  public static function toStringSameAs(expression : Expression, expected : {}) {
    var actual : String = expression.toString();
    Assert.same(expected, actual);
  }
}
