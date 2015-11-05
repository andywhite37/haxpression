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

  public function testContainsAll() {
    Assert.isTrue([].containsAll([]));
    Assert.isTrue([1, 2, 3].containsAll([]));
    Assert.isTrue([1, 2, 3].containsAll([1]));
    Assert.isTrue([1, 2, 3].containsAll([1, 2]));
    Assert.isTrue([1, 2, 3].containsAll([1, 2, 3]));
    Assert.isTrue([1, 2, 3].containsAll([2, 3]));
    Assert.isFalse([1, 2, 3].containsAll([1, 2, 3, 4]));
    Assert.isFalse([1].containsAll([1, 2, 3, 4]));
    Assert.isFalse([].containsAll([1, 2, 3, 4]));
  }

  public function testContainsAny() {
    Assert.isTrue([].containsAny([]));
    Assert.isTrue([1, 2, 3].containsAny([]));
    Assert.isTrue([1, 2, 3].containsAny([1]));
    Assert.isTrue([1, 2, 3].containsAny([1, 2]));
    Assert.isTrue([1, 2, 3].containsAny([1, 2, 3]));
    Assert.isTrue([1, 2, 3].containsAny([2, 3]));
    Assert.isTrue([1, 2, 3].containsAny([1, 2, 3, 4]));
    Assert.isTrue([1].containsAny([1, 2, 3, 4]));
    Assert.isFalse([1, 2, 3].containsAny([4, 5, 6]));
    Assert.isFalse([].containsAny([1, 2, 3, 4]));
  }

  public function testContainsNone() {
    Assert.isTrue([].containsNone([]));
    Assert.isTrue([].containsNone([1, 2, 3]));
    Assert.isTrue([1, 2, 3].containsNone([]));
    Assert.isTrue([].containsNone([4, 5, 6]));
    Assert.isTrue([1].containsNone([4, 5, 6]));
    Assert.isTrue([1, 2].containsNone([4, 5, 6]));
    Assert.isTrue([1, 2, 3].containsNone([4, 5, 6]));
    Assert.isFalse([1, 2, 3].containsNone([3]));
    Assert.isFalse([1, 2, 3].containsNone([3, 4]));
    Assert.isFalse([1, 2, 3].containsNone([3, 4, 5]));
    Assert.isFalse([1, 2, 3].containsNone([3, 4, 5, 6]));
  }
}
