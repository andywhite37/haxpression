package haxpression;

import haxe.ds.Either;
import haxpression.ExpressionType;
import haxpression.ValueType;

abstract ExpressionOrValue(Either<Expression, Value>) {
  public function new(either : Either<Expression, Value>) {
    this = either;
  }

  @:from
  public static function fromEither(either : Either<Expression, Value>) {
    return new ExpressionOrValue(either);
  }

  @:from
  public static function fromExpression(expression : Expression) : ExpressionOrValue {
    return Left(expression);
  }

  @:from
  public static function fromValue(value : Value) : ExpressionOrValue {
    return Right(value);
  }

  @:from
  public static function fromFloat(value : Float) : ExpressionOrValue {
    return fromValue(value);
  }

  @:from
  public static function fromInt(value : Int) : ExpressionOrValue {
    return fromValue(value);
  }

  // Implicit conversion assume strings are expressions, not string values.
  @:from
  public static function fromString(expressionString: String) : ExpressionOrValue {
    return fromExpression(expressionString);
  }

  @:from
  public static function fromBool(value : Bool) : ExpressionOrValue {
    return fromValue(value);
  }

  @:to
  public function toEither() : Either<Expression, Value> {
    return this;
  }

  @:to
  public function toExpression() : Expression {
    return switch this {
      case Left(expression): expression;
      case Right(value): Literal(value);
    };
  }

  @:to
  public function toValue() : Value {
    return switch this {
      case Left(expression): expression.evaluate();
      case Right(value): value;
    };
  }

  public function toDynamic() : Dynamic {
    return switch this {
      case Left(expression) : expression.toDynamic();
      case Right(value) : value.toDynamic();
    };
  }
}
