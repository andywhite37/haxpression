package haxpression;

import haxpression.ExpressionType;
import haxpression.ValueType;
using Lambda;
using StringTools;

class Parser {
  var inputString : String;
  var index : Int;
  var length : Int;
  var expressions : Array<Expression>;

  function new(inputString : String) {
    this.inputString = inputString;
    this.index = 0;
    this.length = inputString.length;
    this.expressions = [];
  }

  public static function parse(input : String) : Expression {
    var parser = new Parser(input);
    return parser.internalParse();
  }

  function internalParse() : Expression {
    while (index < length) {
      var inputCharCode = charCodeAt(index);
      if (inputCharCode == Chars.SEMICOLON_CODE || inputCharCode == Chars.COMMA_CODE) {
        index++;
      } else {
        var expression = gobbleExpression();
        if (expression != null) {
          expressions.push(expression);
        } else if (index < length) {
          throw new Error('Unexpected "${charAt(index)}" at position ${index}');
        }
      }
    }

    return if (expressions.length == 1) {
      expressions[0];
    } else {
      Compound(expressions.map(function(expression) return expression.toExpressionType()));
    }
  }

  function charAt(index : Int) : String {
    return inputString.charAt(index);
  }

  function charCodeAt(index : Int) : Int {
    return inputString.charCodeAt(index);
  }

  function gobbleSpaces() {
    var charCode = charCodeAt(index);
    while (Chars.isWhiteSpace(charCode)) {
      charCode = charCodeAt(++index);
    }
  }

  function gobbleExpression() : Expression {
    var expression = gobbleBinaryExpression();
    var consequent : Expression;
    var alternate : Expression;

    gobbleSpaces();

    if (charCodeAt(index) == Chars.QUESTION_MARK_CODE) {
      index++;
      consequent = gobbleExpression();
      if (consequent == null) {
        throw new Error('expected consequent expression for conditional', index);
      }
      gobbleSpaces();
      if (charCodeAt(index) == Chars.COLON_CODE) {
        index++;
        alternate = gobbleExpression();
        if (alternate == null) {
          throw new Error('expected alternate expression for conditional', index);
        }
        return Conditional(expression, consequent, alternate);
      }
    }

    // Not a conditional - just return the expression
    return expression;
  }

  function gobbleBinaryOperator() : Null<String> {
    gobbleSpaces();
    var toCheck = inputString.substr(index, BinaryOperations.getMaxOperatorLength());
    var toCheckLength = toCheck.length;
    while (toCheckLength > 0) {
      if (BinaryOperations.has(toCheck)) {
        index += toCheckLength;
        return toCheck;
      }
      toCheck = toCheck.substr(0, --toCheckLength);
    }
    return null; // not an operator
  }

  function gobbleBinaryExpression() : Expression {
    gobbleSpaces();
    var expression : Expression;
    var left = gobbleToken();

    var binaryOperator = gobbleBinaryOperator();
    if (binaryOperator == null) {
      return left;
    }

    var binaryOperatorInfo = {
      operator: binaryOperator,
      precedence: BinaryOperations.getOperatorPrecendence(binaryOperator)
    };

    var right = gobbleToken();
    if (right == null) {
      throw new Error('expected expression after $binaryOperator', index);
    }

    var stack : Array<Dynamic> = [left, binaryOperatorInfo, right];

    while ((binaryOperator = gobbleBinaryOperator()) != null) {
      var precedence = BinaryOperations.getOperatorPrecendence(binaryOperator);

      if (precedence == 0) {
        break;
      }

      binaryOperatorInfo = {
        operator: binaryOperator,
        precedence: precedence
      };

      while ((stack.length > 2) && (precedence <= stack[stack.length - 2].precendence)) {
        right = stack.pop();
        binaryOperator = stack.pop().operator;
        left = stack.pop();
        var expression = Binary(binaryOperator, left, right);
        stack.push(expression);
      }

      expression = gobbleToken();
      if (expression == null) {
        throw new Error('expected expression after $binaryOperator', index);
      }
      stack.push(binaryOperatorInfo);
      stack.push(expression);
    }

    var i = stack.length - 1;
    expression = stack[i];
    while (i > 1) {
      expression = Binary(stack[i - 1].operator, stack[i - 2], expression);
      i -= 2;
    }
    return expression;
  }

  function gobbleToken() : Null<Expression> {
    gobbleSpaces();

    var charCode = charCodeAt(index);

    if (Chars.isDecimalDigit(charCode) || charCode == Chars.PERIOD_CODE) {
      return gobbleNumericLiteral();
    } else if (charCode == Chars.SINGLE_QUOTE_CODE || charCode == Chars.DOUBLE_QUOTE_CODE) {
      return gobbleStringLiteral();
    } else if (Chars.isIdentifierStart(charCode) || charCode == Chars.OPEN_PAREN_CODE) {
      return gobbleVariable();
    } else if (charCode == Chars.OPEN_BRACKET_CODE) {
      return gobbleArray();
    } else {
      // Try to gobble unary operator expression
      var toCheck = inputString.substr(index, UnaryOperations.getMaxOperatorLength());
      var toCheckLength = toCheck.length;
      while (toCheckLength > 0) {
        if (UnaryOperations.has(toCheck)) {
          index += toCheckLength;
          return Unary(toCheck, gobbleToken());
        }
        toCheck = toCheck.substr(0, --toCheckLength);
      }

      // No expression found
      return null;
    }
  }

  function gobbleNumericLiteral() : Expression {
    var numberString = "";
    while (Chars.isDecimalDigit(charCodeAt(index))) {
      numberString += charAt(index++);
    }

    if (charCodeAt(index) == Chars.PERIOD_CODE) {
      numberString += charAt(index++);

      while (Chars.isDecimalDigit(charCodeAt(index))) {
        numberString += charAt(index++);
      }
    }

    // check for exponent
    var char = charAt(index);
    if (char == "e" || char == "E") {
      numberString += charAt(index++);
      char = charAt(index);
      if (char == "+" || char == "-") {
        numberString += charAt(index++);
      }

      while (Chars.isDecimalDigit(charCodeAt(index))) {
        numberString += charAt(index++);
      }

      if (!Chars.isDecimalDigit(charCodeAt(index - 1))) {
        throw new Error('expected exponent (${numberString}${charAt(index)})', index);
      }
    }

    var charCode = charCodeAt(index);

    if (Chars.isIdentifierStart(charCode)) {
      throw new Error('variable names cannot start with a number (${numberString}${charAt(index)})', index);
    } else if (charCode == Chars.PERIOD_CODE) {
      throw new Error('unexpected period', index);
    }

    return Literal(Std.parseFloat(numberString));
  }

  function gobbleStringLiteral() : Expression {
    var str = "";
    var quote = charAt(index++);
    var closed = false;

    while (index < length) {
      var char = charAt(index++);
      if (char == quote) {
        closed = true;
        break;
      } else if (char == "\\") {
        char = charAt(index++);
        switch char {
          case "n": str += '\n';
          case "r": str += '\r';
          case "t": str += '\t';
          //case "b": str += '\b'; // haxe error
          //case "f": str += '\f'; // haxe error
          case "v": str += '\x0B';
        };
      } else {
        str += char;
      }
    }

    if (!closed) {
      throw new Error('unclosed quote after "$str"', index);
    }

    return Literal(str);
  }

  function gobbleIdentifier() : Expression {
    var charCode = charCodeAt(index);
    var start = index;
    var identifier : String;

    if (Chars.isIdentifierStart(charCode)) {
      index++;
    } else {
      throw new Error('unexpected ${charAt(index)}', index);
    }

    while (index < length) {
      charCode = charCodeAt(index);
      if (Chars.isIdentifierPart(charCode)){
        index++;
      } else {
        break;
      }
    }

    identifier = inputString.substring(start, index);

    if (identifier == "true") {
      return Literal(true);
    } else if (identifier == "false") {
      return Literal(false);
    } else if (identifier == "null") {
      return Literal(VNone);
    } else {
      return Identifier(identifier);
    }
  }

  function gobbleArguments(terminationCharCode : Int) : Array<Expression> {
    var expressions : Array<Expression> = [];

    while (index < length) {
      gobbleSpaces();
      var charCode = charCodeAt(index);

      if (charCode == terminationCharCode) {
        index++;
        break;
      } else if (charCode == Chars.COMMA_CODE) {
        index++;
      } else {
        var expression = gobbleExpression();
        if (expression == null || expression.isCompound()) {
          throw new Error('expected comma', index);
        }
        expressions.push(expression);
      }
    }

    return expressions;
  }

  function gobbleVariable() : Expression {
    var charCode = charCodeAt(index);
    var expression : Expression;

    if (charCode == Chars.OPEN_PAREN_CODE) {
      expression = gobbleGroup();
    } else {
      expression = gobbleIdentifier();
    }

    gobbleSpaces();

    charCode = charCodeAt(index);

    while (charCode == Chars.PERIOD_CODE || charCode == Chars.OPEN_BRACKET_CODE || charCode == Chars.OPEN_PAREN_CODE) {
      index++;

      if (charCode == Chars.PERIOD_CODE) {
        // TODO: add support for this?
        throw new Error('member expressions (. access) are not supported', index);
      } else if (charCode == Chars.OPEN_BRACKET_CODE) {
        // TODO: add support for this?
        throw new Error('member expressions ([] access) are not supported', index);
      } else if (charCode == Chars.OPEN_PAREN_CODE) {
        var callee = switch expression.toExpressionType() {
          case Identifier(name) : name;
          case _: throw new Error('expected identifier expression', index);
        };
        var arguments = gobbleArguments(Chars.CLOSE_PAREN_CODE)
          .map(function(expression) return expression.toExpressionType());
        expression = Call(callee, arguments);
      }
      gobbleSpaces();
      charCode = charCodeAt(index);
    }

    return expression;
  }


  function gobbleGroup() : Expression {
    index++;
    var expression = gobbleExpression();

    if (charCodeAt(index) == Chars.CLOSE_PAREN_CODE) {
      index++;
      return expression;
    } else {
      throw new Error('unclosed (', index);
    }
  }

  function gobbleArray() : Expression {
    index++;
    var items = gobbleArguments(Chars.CLOSE_BRACKET_CODE)
      .map(function(expression) return expression.toExpressionType());
    return Array(items);
  }
}
