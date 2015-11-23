package haxpression.utils;

using haxpression.utils.Iterators;
using Lambda;

class Maps {
  public static function values<TKey, TValue>(map : Map<TKey, TValue>) : Array<TValue> {
    return map.keys().map(function(key) {
      return map[key];
    });
  }

  public static function mapValues<TKey, TValueIn, TValueOut>(map : Map<TKey, TValueIn>, mapper : TKey -> TValueIn -> TValueOut, seed : Map<TKey, TValueOut>) : Map<TKey, TValueOut> {
    return map.keys().toArray().fold(function(key, acc : Map<TKey, TValueOut>) {
      var valueIn = map.get(key);
      var valueOut = mapper(key, valueIn);
      acc.set(key, valueOut);
      return acc;
    }, seed);
  }
}
