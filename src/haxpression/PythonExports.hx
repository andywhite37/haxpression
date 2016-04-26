package haxpression;

import python.Dict;

typedef MappingInfo = {
  mappingExpressions: Dict<String, Dict<String, Dynamic>>,
  externalVariables: Array<String>,
  sortedComputedVariables: Array<String>,
};

class PythonExports {
#if python
  @:keep
  public static function getMappingInfo(mappings : Dict<String, Array<String>>, requestedFields: Array<String>) : MappingInfo {
    throw 'not implemented';
  }

  @:keep
  public static function parseToObject(s : String) : python.Dict<String, Dynamic> {
    return toDict(Expression.fromString(s));
  }

  static function dictToMap(dict : Dict<String, Dynamic>) : Map<String, Value> {
    var map : Map<String, Value> = new Map();
    var o = python.Lib.dictToAnon(dict);
    for(field in Reflect.fields(o)) {
      map.set(field, Value.fromDynamic(Reflect.field(o, field)));
    }
    return map;
  }

  @:keep
  public static function parseEvaluate(s : String, dict : python.Dict<String, Dynamic>) {
    var map = dictToMap(dict);
    return Expression.fromString(s).evaluate(map).toDynamic();
  }

  @:keep
  public static function toDict(expression : Expression) : python.Dict<String, Dynamic> {
    return python.Lib.anonToDict(switch expression.toExpressionType() {
      case Literal(value) : {
        type: "Literal",
        value: new Value(value).toDynamic() // allow the value to be passed-through with no conversion
      };
      case Identifier(name) : {
        type: "Identifier",
        name: name
      };
      case Unary(operator, operand) : {
        type: "Unary",
        operator: operator,
        operand: toDict(operand),
      };
      case Binary(operator, left, right) : {
        type: "Binary",
        operator: operator,
        left: toDict(left),
        right: toDict(right)
      };
      case Call(callee, arguments): {
        type: "Call",
        callee: callee,
        arguments: arguments.map(function(arg) return toDict(Expression.fromExpressionType(arg)))
      };
      case Conditional(test, consequent, alternate): {
        type: "Conditional",
        test: toDict(test),
        consequent: toDict(consequent),
        alternate: toDict(alternate)
      };
      case Array(items) : {
        type: "Array",
        items: items.map(function(item) return toDict(Expression.fromExpressionType(item)))
      };
      case Compound(items) : {
        type: "Compound",
        items: items.map(function(item) return toDict(Expression.fromExpressionType(item)))
      };
    });
  }
#end
}
