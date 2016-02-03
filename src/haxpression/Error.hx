package haxpression;

class Error {
  public var message(default, null) : String;
  public var expression(default, null) : String;
  public var position(default, null) : Null<Int>;

  public function new(message : String, ?expression : String, ?position : Int) {
    this.message = message;
    this.expression = expression;
    this.position = position;
  }

  public function toString() {
    var expressionInfo = expression != null ? ' in expression: "$expression"' : '';
    var positionInfo = position != null ? ' at position: $position' : '';
    return '${message}${expressionInfo}${positionInfo}';
  }
}
