package haxpression;

import Lambda;
import haxpression.ValueType;
using haxpression.utils.Arrays;
using haxpression.utils.Iterators;

class BinaryOperations {
  static var map(default, null) : Map<String, { precedence : Int, operation: Value -> Value -> Value }>;

  public static function __init__() {
    map = new Map();
    // Higher numbers have higher precedence (higher precedence ops will be evaluated before lower)
    addOperator("||", 1, function(left, right) return left.toBool() || right.toBool());
    addOperator("&&", 2, function(left, right) return left.toBool() && right.toBool());
    addOperator("|", 3, function(left, right) return left.toInt() | right.toInt());
    addOperator("^", 4, function(left, right) return left.toInt() ^ right.toInt());
    addOperator("&", 5, function(left, right) return left.toInt() & right.toInt());
    addOperator("==", 6, function(left, right) return left.toFloat() == right.toFloat());
    addOperator("!=", 6, function(left, right) return left.toFloat() != right.toFloat());
    addOperator("<", 7, function(left, right) return left.toFloat() < right.toFloat());
    addOperator(">", 7, function(left, right) return left.toFloat() > right.toFloat());
    addOperator("<=", 7, function(left, right) return left.toFloat() <= right.toFloat());
    addOperator(">=", 7, function(left, right) return left.toFloat() >= right.toFloat());
    addOperator("<<", 8, function(left, right) return left.toInt() << right.toInt());
    addOperator(">>", 8, function(left, right) return left.toInt() >> right.toInt());
    addOperator(">>>", 8, function(left, right) return left.toInt() >>> right.toInt());
    addOperator("+", 9, function(left, right) return left.toFloat() + right.toFloat());
    addOperator("-", 9, function(left, right) return left.toFloat() - right.toFloat());
    addOperator("*", 10, function(left, right) return left.toFloat() * right.toFloat());
    addOperator("/", 10, function(left, right) return left.toFloat() / right.toFloat());
    addOperator("%", 10, function(left, right) return left.toFloat() % right.toFloat());
    addOperator("**", 11, function(left, right) return Math.pow(left.toFloat(), right.toFloat()));
  }

  public static function evaluate(operator, left : Value, right : Value) : Value {
    return map.get(operator).operation(left, right);
  }

  public static function addOperator(operator : String, precedence : Int, operation : Value -> Value -> Value) {
    map.set(operator, {
      precedence: precedence,
      operation: wrapOperation(operation)
    });
  }

  public static function removeOperator(operator : String) {
    map.remove(operator);
  }

  public static function hasOperator(operator : String) : Bool {
    return map.exists(operator);
  }

  public static function clearOperators() {
    map = new Map();
  }

  public static function getOperatorPrecedence(operator : String) : Int {
    return map.get(operator).precedence;
  }

  public static function getMaxOperatorLength() : Int {
    return map.keys().toArray().reduce(function(maxLength : Int, key : String) : Int {
      return key.length > maxLength ? key.length : maxLength;
    }, 0);
  }

  static function wrapOperation(operation : Value -> Value -> Value) : Value -> Value -> Value {
    return function(left : Value, right : Value) : Value {
      return if (left.isNA() || right.isNA()) return VNA;
        else if (left.isNM() || right.isNM()) return VNM;
        else operation(left, right);
    }
  }
}
