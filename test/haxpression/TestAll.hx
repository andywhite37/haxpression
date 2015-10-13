package haxpression;

import haxpression.utils.*;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function addTests(runner : Runner) {
    runner.addCase(new TestArrays());
    runner.addCase(new TestChars());
    runner.addCase(new TestStrings());
    runner.addCase(new TestExpression());
    runner.addCase(new TestParser());
    runner.addCase(new TestValue());
  }

  public static function main() {
    var runner = new Runner();
    addTests(runner);
    Report.create(runner);
    runner.run();
  }
}
