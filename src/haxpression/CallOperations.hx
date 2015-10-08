package haxpression;

class CallOperations {
  static var map(default, null) : Map<String, { arity: Int, operation: Array<Value> -> Value }>;

  public static function __init__() {
    map = new Map();
    add("abs", 1, function(arguments) return Math.abs(arguments[0].toFloat()));
    add("acos", 1, function(arguments) return Math.acos(arguments[0].toFloat()));
    add("asin", 1, function(arguments) return Math.asin(arguments[0].toFloat()));
    add("atan", 1, function(arguments) return Math.atan(arguments[0].toFloat()));
    add("atan2", 2, function(arguments) return Math.atan2(arguments[0].toFloat(), arguments[1].toFloat()));
    add("ceil", 1, function(arguments) return Math.ceil(arguments[0].toFloat()));
    add("cos", 1, function(arguments) return Math.cos(arguments[0].toFloat()));
    add("exp", 1, function(arguments) return Math.exp(arguments[0].toFloat()));
    add("fceil", 1, function(arguments) return Math.fceil(arguments[0].toFloat()));
    add("ffloor", 1, function(arguments) return Math.ffloor(arguments[0].toFloat()));
    add("floor", 1, function(arguments) return Math.floor(arguments[0].toFloat()));
    add("fround", 1, function(arguments) return Math.fround(arguments[0].toFloat()));
    add("log", 1, function(arguments) return Math.log(arguments[0].toFloat()));
    add("max", 2, function(arguments) return Math.max(arguments[0].toFloat(), arguments[1].toFloat()));
    add("min", 2, function(arguments) return Math.min(arguments[0].toFloat(), arguments[1].toFloat()));
    add("pow", 2, function(arguments) return Math.pow(arguments[0].toFloat(), arguments[1].toFloat()));
    add("random", 0, function(arguments) return Math.random());
    add("round", 1, function(arguments) return Math.round(arguments[0].toFloat()));
    add("sin", 1, function(arguments) return Math.sin(arguments[0].toFloat()));
    add("sqrt", 1, function(arguments) return Math.sqrt(arguments[0].toFloat()));
    add("tan", 1, function(arguments) return Math.tan(arguments[0].toFloat()));
  }

  public static function add(callee : String, arity: Int, operation : Array<Value> -> Value) : Void {
    map.set(callee, { arity: arity, operation: wrapOperation(callee, arity, operation) });
  }

  public static function remove(callee : String) : Void {
    map.remove(callee);
  }

  public static function has(callee : String) : Bool {
    return map.exists(callee);
  }

  public static function evaluate(callee : String, arguments : Array<Value>) : Value {
    if (!has(callee)) {
      throw new Error('no function implementation given for function name: $callee');
    }
    return map.get(callee).operation(arguments);
  }

  static function wrapOperation(callee : String, arity : Int, operation : Array<Value> -> Value) : Array<Value> -> Value {
    return function(arguments) {
      if (arguments.length != arity) {
        throw new Error('function $callee expects exactly $arity arguments');
      }
      return operation(arguments);
    };
  }
}
