package haxpression;

import python.Dict;
using Lambda;
using haxpression.utils.Maps;

typedef PythonEvaluationInfo = {
  expressionAsts: Dict<String, Dynamic>,
  externalVariables: Array<String>,
  sortedComputedVariables: Array<String>,
};

class PythonExports {
#if python
  @:keep
  public static function getEvaluationInfo(mappings : Dict<String, Array<String>>, requestedFieldIds: Array<String>) : Dict<String, Dynamic> {
    // TODO: replace all the anon mapping crap with proper haxe python.Dict usage

    var obj = python.Lib.dictToAnon(mappings);

    var map : Map<String, Array<ExpressionOrValue>> = new Map();
    for (field in Reflect.fields(obj)) {
      var arr : Array<String> = Reflect.field(obj, field);
      //trace(field, arr);
      map.set(field, arr.map(ExpressionOrValue.fromString));
    }
    var expressionGroup = ExpressionGroup.fromFallbackMap(map);
    var info = expressionGroup.getEvaluationInfo(requestedFieldIds);

    var expressionAstsObj = {};
    for (key in info.expressions.keys()) {
      Reflect.setField(expressionAstsObj, key, expressionToDict(info.expressions.get(key)));
    }

    //trace(haxe.Json.stringify(anonExpressionAsts));

    var result = {
      expressionAsts: python.Lib.anonToDict(expressionAstsObj),
      externalVariables: info.externalVariables,
      sortedComputedVariables: info.sortedComputedVariables
    };

    //trace(haxe.Json.stringify(result, null, '  '));

    return python.Lib.anonToDict(result);
  }

  @:keep
  public static function parseToObject(s : String) : python.Dict<String, Dynamic> {
    return expressionToDict(Expression.fromString(s));
  }

  @:keep
  public static function parseEvaluate(s : String, dict : python.Dict<String, Dynamic>) {
    var map : Map<String, Value> = new Map();
    var o = python.Lib.dictToAnon(dict);
    for(field in Reflect.fields(o)) {
      map.set(field, Value.fromDynamic(Reflect.field(o, field)));
    }
    return Expression.fromString(s).evaluate(map).toDynamic();
  }

  @:keep
  public static function expressionToDict(expression : Expression) : python.Dict<String, Dynamic> {
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
        operand: expressionToDict(operand),
      };
      case Binary(operator, left, right) : {
        type: "Binary",
        operator: operator,
        left: expressionToDict(left),
        right: expressionToDict(right)
      };
      case Call(callee, arguments): {
        type: "Call",
        callee: callee,
        arguments: arguments.map(function(arg) return expressionToDict(Expression.fromExpressionType(arg)))
      };
      case Conditional(test, consequent, alternate): {
        type: "Conditional",
        test: expressionToDict(test),
        consequent: expressionToDict(consequent),
        alternate: expressionToDict(alternate)
      };
      case Array(items) : {
        type: "Array",
        items: items.map(function(item) return expressionToDict(Expression.fromExpressionType(item)))
      };
      case Compound(items) : {
        type: "Compound",
        items: items.map(function(item) return expressionToDict(Expression.fromExpressionType(item)))
      };
    });
  }
#end
}
