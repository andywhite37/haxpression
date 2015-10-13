package haxpression.utils;

import utest.Assert;

class TestChars {
  public function new() {
  }

  public function testIsDecimalDigit() {
    Assert.isTrue(Chars.isDecimalDigit("0".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("1".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("2".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("3".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("4".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("5".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("6".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("7".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("8".charCodeAt(0)));
    Assert.isTrue(Chars.isDecimalDigit("9".charCodeAt(0)));
    Assert.isFalse(Chars.isDecimalDigit("a".charCodeAt(0)));
    Assert.isFalse(Chars.isDecimalDigit("!".charCodeAt(0)));
  }

  public function testIsWhiteSpace() {
    Assert.isTrue(Chars.isWhiteSpace(" ".charCodeAt(0)));
    Assert.isTrue(Chars.isWhiteSpace("\t".charCodeAt(0)));
    Assert.isTrue(Chars.isWhiteSpace("\n".charCodeAt(0)));
    Assert.isTrue(Chars.isWhiteSpace("\r".charCodeAt(0)));
  }
}
