package haxpression;

class CallOperations {
  static var map(default, null) : Map<String, { arity: Int, operation: Array<Value> -> Value }>;

  public static function __init__() {
    map = new Map();
    addFunction("abs", 1, function(arguments) return Math.abs(arguments[0].toFloat()));
    addFunction("acos", 1, function(arguments) return Math.acos(arguments[0].toFloat()));
    addFunction("asin", 1, function(arguments) return Math.asin(arguments[0].toFloat()));
    addFunction("atan", 1, function(arguments) return Math.atan(arguments[0].toFloat()));
    addFunction("atan2", 2, function(arguments) return Math.atan2(arguments[0].toFloat(), arguments[1].toFloat()));
    addFunction("ceil", 1, function(arguments) return Math.ceil(arguments[0].toFloat()));
    addFunction("cos", 1, function(arguments) return Math.cos(arguments[0].toFloat()));
    addFunction("exp", 1, function(arguments) return Math.exp(arguments[0].toFloat()));
    addFunction("fceil", 1, function(arguments) return Math.fceil(arguments[0].toFloat()));
    addFunction("ffloor", 1, function(arguments) return Math.ffloor(arguments[0].toFloat()));
    addFunction("floor", 1, function(arguments) return Math.floor(arguments[0].toFloat()));
    addFunction("fround", 1, function(arguments) return Math.fround(arguments[0].toFloat()));
    addFunction("log", 1, function(arguments) return Math.log(arguments[0].toFloat()));
    addFunction("max", 2, function(arguments) return Math.max(arguments[0].toFloat(), arguments[1].toFloat()));
    addFunction("min", 2, function(arguments) return Math.min(arguments[0].toFloat(), arguments[1].toFloat()));
    addFunction("pow", 2, function(arguments) return Math.pow(arguments[0].toFloat(), arguments[1].toFloat()));
    addFunction("random", 0, function(arguments) return Math.random());
    addFunction("round", 1, function(arguments) return Math.round(arguments[0].toFloat()));
    addFunction("sin", 1, function(arguments) return Math.sin(arguments[0].toFloat()));
    addFunction("sqrt", 1, function(arguments) return Math.sqrt(arguments[0].toFloat()));
    addFunction("tan", 1, function(arguments) return Math.tan(arguments[0].toFloat()));
  }

  public static function addFunction(callee : String, arity: Int, operation : Array<Value> -> Value) : Void {
    map.set(callee, { arity: arity, operation: wrapOperation(callee, arity, operation) });
  }

  public static function removeFunction(callee : String) : Void {
    map.remove(callee);
  }

  public static function hasFunction(callee : String) : Bool {
    return map.exists(callee);
  }

  public static function clearFunctions() : Void {
    map = new Map();
  }

  public static function evaluate(callee : String, arguments : Array<Value>) : Value {
    if (!hasFunction(callee)) {
      throw new Error('no function implementation found for function name: $callee');
    }
    return map.get(callee).operation(arguments);
  }

  static function wrapOperation(callee : String, arity : Int, operation : Array<Value> -> Value) : Array<Value> -> Value {
    return function(arguments) {
      if (arity >= 0 && arguments.length != arity) {
        throw new Error('function $callee expects exactly $arity argument(s)');
      }
      return operation(arguments);
    };
  }
}
