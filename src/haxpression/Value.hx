package haxpression;

import haxpression.ValueType;
using Lambda;

abstract Value(ValueType) {
  public static var NONE_STRING(default, never) = "NA";
  public static var NONE_PARSE_STRINGS(default, never) = [NONE_STRING, "", "none", "N/A"];
  public static var TRUE_STRING(default, never) = "true";
  public static var FALSE_STRING(default, never) = "false";

  public function new(valueType : ValueType) {
    this = valueType;
  }

  @:from
  public static function fromValueType(valueType : ValueType) : Value {
    return new Value(valueType);
  }

  @:to
  public function toValueType() : ValueType {
    return this;
  }

  @:from
  public static function fromFloat(v : Float) : Value {
    return VFloat(v);
  }

  @:from
  public static function fromInt(v : Int) : Value {
    return VInt(v);
  }

  @:from
  public static function fromBool(v : Bool) : Value {
    return VBool(v);
  }

  @:from
  public static function fromString(v : String) : Value {
    // null value becomes VNone
    if (v == null || v == "null") {
      return VNone;
    }

    // None-like strings become VNone
    var match = NONE_PARSE_STRINGS.find(function(str) return str == v);
    if (match != null) {
      return VNone;
    }

    if (v == TRUE_STRING) {
      return VBool(true);
    }

    if (v == FALSE_STRING) {
      return VBool(false);
    }

    return try {
      VFloat(Std.parseFloat(v));
    } catch (e : Dynamic) {
      VNone;
    }
  }

  @:to
  public function toFloat() : Float {
    return switch this {
      case VFloat(v) : v;
      case VInt(v) : v;
      case VBool(v) : throw new Error('cannot convert VBool to Float');
      case VString(v) : throw new Error('cannot convert VSTring to Float');
      case VNone : throw new Error('cannot convert VNone to Float');
    };
  }

  @:to
  public function toInt() : Int {
    return switch this {
      case VFloat(v) : Std.int(v);
      case VInt(v) : v;
      case VBool(v) : throw new Error('cannot convert VBool to Int');
      case VString(v) : throw new Error('cannot convert VString to Int');
      case VNone : throw new Error('cannot convert VNone to Int');
    };
  }

  @:to
  public function toBool() : Bool {
    return switch this {
      case VFloat(v) : v != 0;
      case VInt(v) : v != 0;
      case VBool(v) : v;
      case VString(v) : v == TRUE_STRING;
      case VNone : throw new Error('cannot convert VNone to Bool');
    };
  }

  public function toDynamic() : Dynamic {
    return switch this {
      case VFloat(v) : v;
      case VInt(v) : v;
      case VBool(v) : v;
      case VString(v) : v;
      case VNone : null;
    };
  }

  public function isNumeric() : Bool {
    return switch this {
      case VFloat(v) : true;
      case VInt(v) : true;
      case _: false;
    };
  }

  public function isNone() : Bool {
    return switch this {
      case VNone: true;
      case _: false;
    };
  }

  public function toString() : String {
    return switch this {
      case VFloat(v) : Std.string(v);
      case VInt(v) : Std.string(v);
      case VBool(v) : v ? TRUE_STRING : FALSE_STRING;
      case VString(v) : v;
      case VNone : NONE_STRING;
    };
  }
}
