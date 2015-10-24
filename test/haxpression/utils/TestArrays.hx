package haxpression.utils;

import utest.Assert;
using haxpression.utils.Arrays;

class TestArrays {
  public function new() {
  }

  public function testAll() {
    Assert.isTrue([1, 2, 3].all(function(i) return i > 0));
    Assert.isFalse([-1, 2, 3].all(function(i) return i > 0));
    Assert.isFalse([-1, -2, 3].all(function(i) return i > 0));
    Assert.isFalse([-1, -2, -3].all(function(i) return i > 0));
    Assert.isFalse([1, -2, -3].all(function(i) return i > 0));
    Assert.isFalse([1, 2, -3].all(function(i) return i > 0));
  }

  public function testAny() {
    Assert.isTrue([1, 2, 3].any(function(i) return i > 0));
    Assert.isTrue([1, 2, -3].any(function(i) return i > 0));
    Assert.isTrue([1, -2, -3].any(function(i) return i > 0));
    Assert.isFalse([-1, -2, -3].any(function(i) return i > 0));
  }

  public function testReduce() {
    Assert.same({ sum: 15, product: 120 }, [1, 2, 3, 4, 5].reduce(function(acc, i) {
      acc.sum += i;
      acc.product *= i;
      return acc;
    }, { sum: 0, product: 1 }));
  }
}
