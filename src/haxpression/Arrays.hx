package haxpression;

using Lambda;

class Arrays {
  public static function any<T>(items : Array<T>, check : T -> Bool) : Bool {
    return items.find(check) != null;
  }

  public static function all<T>(items : Array<T>, check : T -> Bool) : Bool {
    return items.filter(check).length == items.length;
  }
}
