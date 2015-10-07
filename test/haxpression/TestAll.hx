package haxpression;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

class TestAll {
  public static function addTests(runner : Runner) {
    runner.addCase(new TestExpression());
    runner.addCase(new TestValue());
    runner.addCase(new TestParser());
  }

  public static function main() {
    var runner = new Runner();
    addTests(runner);
    Report.create(runner);
    runner.run();
  }
}
