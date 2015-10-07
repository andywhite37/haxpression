package haxpression;

class Error {
  public var message(default, null) : String;
  public var position(default, null) : Null<Int>;

  public function new(message : String, ?position : Int) {
    this.message = message;
    this.position = position;
  }

  public function toString() {
    var positionInfo = position != null ?  ' (position: $position)' : '';
    return '${message}${positionInfo}';
  }
}
