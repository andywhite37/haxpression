package haxpression.utils;

import haxpression.Value;
using haxpression.utils.Iterators;

class StringValueMaps {
  public static function equals(map : Map<String, Value>, other : Map<String, Value>) : Bool {
    if (map.keys().toArray().length != other.keys().toArray().length) return false;
    for (key in map.keys())
      if (!map.get(key).equals(other.get(key))) return false;
    return true;
  }
}
