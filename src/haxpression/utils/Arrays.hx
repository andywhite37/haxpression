package haxpression.utils;

using Lambda;

class Arrays {
  public static function any<T>(items : Array<T>, check : T -> Bool) : Bool {
    return items.find(check) != null;
  }

  public static function all<T>(items : Array<T>, check : T -> Bool) : Bool {
    return items.filter(check).length == items.length;
  }

  public static function reduce<T, TResult>(items : Array<T>, callback : T -> TResult -> TResult, acc : TResult) : TResult {
    for (item in items) {
      acc = callback(item, acc);
    }
    return acc;
  }
}
