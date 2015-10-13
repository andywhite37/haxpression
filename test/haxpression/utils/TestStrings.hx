package haxpression.utils;

import utest.Assert;
using haxpression.utils.Strings;

class TestStrings {
  public function new() {
  }

  public function testContains() {
    Assert.isTrue("my string".contains("my"));
    Assert.isTrue("my string".contains("y s"));
    Assert.isTrue("my string".contains("r"));
    Assert.isTrue("my string".contains("ing"));
  }

  public function testIContains() {
    Assert.isTrue("my string".icontains("My"));
    Assert.isTrue("my string".icontains("y S"));
    Assert.isTrue("my string".icontains("R"));
    Assert.isTrue("my string".icontains("ING"));
  }
}
