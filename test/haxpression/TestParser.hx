package haxpression;

import utest.Assert;

class TestParser {
  public function new() {
  }

  public function testBasic() {
    var input = "(1 / (2 - 3)) * IQ_SALES";
    var expression = Parser.parse(input);

    trace(expression.toString());
    trace(expression.toObject());
    trace(expression.getVariables());

    try {
      trace(expression.evaluate());
      Assert.fail();
    } catch (e : Error) {
      trace('caught expected exception ${e.message}');
    }

    expression = expression.substituteValue("IQ_SALES", Math.PI);

    trace(expression.toString());
    trace(expression.toObject());
    trace(expression.getVariables());
    trace(expression.evaluate());

    Assert.isTrue(true);
  }
}
