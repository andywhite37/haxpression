package haxpression.utils;

using Lambda;

class Arrays {
  public static function contains<T>(items : Array<T>, item : T) : Bool {
    return items.indexOf(item) != -1;
  }

  public static function each<T>(items : Array<T>, callback : T -> Void) : Void {
    return items.iter(callback);
  }

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
