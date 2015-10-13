package haxpression.utils;

using haxpression.utils.Iterators;

class Maps {
  public static function values<TKey, TValue>(map : Map<TKey, TValue>) : Array<TValue> {
    return map.keys().map(function(key) {
      return map[key];
    });
  }
}
