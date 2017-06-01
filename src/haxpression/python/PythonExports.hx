package haxpression.python;

import haxe.Timer.measure;

import python.Dict;

typedef PythonEvaluationInfo = {
  expressionAsts: Dict<String, Dynamic>,
  externalVariables: Array<String>,
  sortedComputedVariables: Array<String>,
};

class PythonExports {
#if python
  @:keep
  public static var loggingEnabled(default, default) = false;

  @:keep
  public static function getEvaluationInfo(mappings : Dict<String, Array<String>>, requestedFieldIds: Array<String>) : Dict<String, Dynamic> {
    var mappingsObj : {} = traceMeasure('convert mappings to python dict', function() {
      return python.Lib.dictToAnon(mappings);
    });

    var fieldIdToExpressionsMap : Map<String, Array<ExpressionOrValue>> = new Map();

    traceMeasure('parse all expressions', function() {
      for (fieldId in Reflect.fields(mappingsObj)) {
        var fieldExpressions : Array<String> = Reflect.field(mappingsObj, fieldId);
        //trace(field, arr);
        fieldIdToExpressionsMap.set(fieldId, fieldExpressions.map(ExpressionOrValue.fromString));
      }
    });

    var expressionGroup = traceMeasure('create expression group (variable graph)', function() {
      return ExpressionGroup.fromFallbackMap(fieldIdToExpressionsMap);
    });

    var evaluationInfo = traceMeasure('process expression group (get external variables, topological sort)', function() {
      return expressionGroup.getEvaluationInfo(requestedFieldIds);
    });

    var expressionAstsObj = {};
    traceMeasure('convert expression ASTs to python dict', function() {
      for (key in evaluationInfo.expressions.keys()) {
        Reflect.setField(expressionAstsObj, key, expressionToDict(evaluationInfo.expressions.get(key)));
      }
    });
    //trace(haxe.Json.stringify(anonExpressionAsts));

    var result = {
      expressionAsts: python.Lib.anonToDict(expressionAstsObj),
      externalVariables: evaluationInfo.externalVariables,
      sortedComputedVariables: evaluationInfo.sortedComputedVariables
    };

    var pythonResult = traceMeasure('convert final result to python dict', function() {
      return python.Lib.anonToDict(result);
    });
    //trace(haxe.Json.stringify(result, null, '  '));

    return pythonResult;
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
      case ELiteral(value) : {
        type: "Literal",
        value: new Value(value).toDynamic() // allow the value to be passed-through with no conversion
      };
      case EIdentifier(name) : {
        type: "Identifier",
        name: name
      };
      case EUnary(operator, operand) : {
        type: "Unary",
        operator: operator,
        operand: expressionToDict(operand),
      };
      case EBinary(operator, left, right) : {
        type: "Binary",
        operator: operator,
        left: expressionToDict(left),
        right: expressionToDict(right)
      };
      case ECall(callee, arguments): {
        type: "Call",
        callee: callee,
        arguments: arguments.map(function(arg) return expressionToDict(Expression.fromExpressionType(arg)))
      };
      case EConditional(test, consequent, alternate): {
        type: "Conditional",
        test: expressionToDict(test),
        consequent: expressionToDict(consequent),
        alternate: expressionToDict(alternate)
      };
      case EArray(items) : {
        type: "Array",
        items: items.map(function(item) return expressionToDict(Expression.fromExpressionType(item)))
      };
      case ECompound(items) : {
        type: "Compound",
        items: items.map(function(item) return expressionToDict(Expression.fromExpressionType(item)))
      };
    });
  }

  static inline function traceMeasure<T>(message : String, f : Void -> T) : T {
    if (loggingEnabled) {
      trace('${Date.now()} - haxpression: ${message}');
      return measure(f);
    } else {
      return f();
    }
  }
#end
}
