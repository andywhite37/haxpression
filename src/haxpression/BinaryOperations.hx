package haxpression;

import Lambda;
import haxpression.ValueType;

class BinaryOperations {
  static var map(default, null) : Map<String, { precedence : Int, operation: Value -> Value -> Value }>;

  public static function __init__() {
    map = new Map();
    // Higher numbers have higher precedence (higher precedence ops will be evaluated before lower)
    add("||", 1, function(left, right) return left.toBool() || right.toBool());
    add("&&", 2, function(left, right) return left.toBool() && right.toBool());
    add("|", 3, function(left, right) return left.toInt() | right.toInt());
    add("^", 4, function(left, right) return left.toInt() ^ right.toInt());
    add("&", 5, function(left, right) return left.toInt() & right.toInt());
    add("==", 6, function(left, right) return left.toFloat() == right.toFloat());
    add("!=", 6, function(left, right) return left.toFloat() != right.toFloat());
    add("<", 7, function(left, right) return left.toFloat() < right.toFloat());
    add(">", 7, function(left, right) return left.toFloat() > right.toFloat());
    add("<=", 7, function(left, right) return left.toFloat() <= right.toFloat());
    add(">=", 7, function(left, right) return left.toFloat() >= right.toFloat());
    add("<<", 8, function(left, right) return left.toInt() << right.toInt());
    add(">>", 8, function(left, right) return left.toInt() >> right.toInt());
    add(">>>", 8, function(left, right) return left.toInt() >>> right.toInt());
    add("+", 9, function(left, right) return left.toFloat() + right.toFloat());
    add("-", 9, function(left, right) return left.toFloat() - right.toFloat());
    add("*", 10, function(left, right) return left.toFloat() * right.toFloat());
    add("/", 10, function(left, right) return left.toFloat() / right.toFloat());
    add("%", 10, function(left, right) return left.toFloat() % right.toFloat());
    add("**", 11, function(left, right) return Math.pow(left.toFloat(), right.toFloat()));
  }

  public static function evaluate(operator, left : Value, right : Value) : Value {
    return map.get(operator).operation(left, right);
  }

  public static function add(operator : String, precedence : Int, operation : Value -> Value -> Value) {
    map.set(operator, {
      precedence: precedence,
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

  public static function getOperatorPrecedence(operator : String) : Int {
    return map.get(operator).precedence;
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

  static function wrapOperation(operation : Value -> Value -> Value) : Value -> Value -> Value {
    return function(left : Value, right : Value) : Value {
      return if (left.isNA() || right.isNA()) return VNA;
        else if (left.isNM() || right.isNM()) return VNM;
        else operation(left, right);
    }
  }
}
