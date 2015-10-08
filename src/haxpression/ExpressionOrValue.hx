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
  public static function fromValue(value : Value) : ExpressionOrValue {
    return Left(value);
  }

  @:from
  public static function fromExpression(expression : Expression) : ExpressionOrValue {
    return Right(value);
  }

  @:to
  public function toEither() : Either<Expression, Value>) {
    return this;
  }

  @:to
  public function toValue() : Value {
    return switch this {
      case Left(expression): expression.evaluate();
      case Right(value): value;
    };
  }

  @:to
  public function toExpression() : Expression {
    return switch this {
      case Left(expression): expression;
      case Right(value): Literal(value);
    };
  }
}
