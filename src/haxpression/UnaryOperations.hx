package haxpression;

import Lambda;
import haxpression.ValueType;

class UnaryOperations {
  static var map(default, null) : Map<String, { operation: Value -> Value }>;

  public static function __init__() {
    map = new Map();
    add("-", function(value) return value.toFloat() * -1);
    add("+", function(value) return value.toFloat() * 1);
    add("!", function(value) return !(value.toBool()));
    add("~", function(value) return ~(value.toInt()));
  }

  public static function evaluate(operator : String, value : Value) : Value {
    return map.get(operator).operation(value);
  }

  public static function add(operator : String, operation : Value -> Value) {
    map.set(operator, {
      operation: wrapOperation(operation)
    });
  }

  public static function remove(operator : String) {
    map.remove(operator);
  }

  public static function has(operator : String) : Bool {
    return map.exists(operator);
  }

  public static function clear() {
    map = new Map();
  }

  public static function getMaxOperatorLength() : Int {
    var max = 0;
    for (key in map.keys()) {
      if (key.length > max) {
        max = key.length;
      }
    }
    return max;
  }

  static function wrapOperation(operation : Value -> Value) : Value -> Value {
    return function(value : Value) : Value {
      if (value.isNone()) {
        return VNone;
      }
      return operation(value);
    }
  }
}
