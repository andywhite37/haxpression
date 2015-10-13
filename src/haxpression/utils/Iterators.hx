package haxpression.utils;

using Lambda;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;

class Iterators {
  public static function contains<T>(iterator : Iterator<T>, target : T) {
    for (value in iterator) {
      if (value == target) {
        return true;
      }
    }
    return false;
  }

  public static function toArray<T>(iterator : Iterator<T>) {
    var result : Array<T> = [];
    for (value in iterator) {
      result.push(value);
    }
    return result;
  }

  public static function map<T, TResult>(iterator : Iterator<T>, callback : T -> TResult) : Array<TResult> {
    return iterator.toArray().map(callback);
  }

  public static function each<T, TResult>(iterator : Iterator<T>, callback : T -> TResult) : Void {
    iterator.toArray().iter(callback);
  }
}
