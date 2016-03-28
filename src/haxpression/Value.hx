package haxpression;

import haxpression.ValueType;
using StringTools;
using haxpression.utils.Arrays;
using haxpression.utils.Strings;

abstract Value(ValueType) {
  static var NA_STRING(default, never) = "na";
  static var NM_STRING(default, never) = "nm";
  static var NULL_STRING(default, never) = "null";
  static var TRUE_STRING(default, never) = "true";
  static var FALSE_STRING(default, never) = "false";

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
    if (v.isEmpty()) return VNA;
    var vl = v.toLowerCase();
    return if (vl == NULL_STRING || vl == NA_STRING) VNA;
      else if (vl == NM_STRING) VNM;
      else if (vl == TRUE_STRING) VBool(true);
      else if (vl == FALSE_STRING) VBool(false);
      else if (stringIsInt(v)) VInt(Std.parseInt(v));
      else if (stringIsFloat(v)) VFloat(Std.parseFloat(v));
      else VString(v);
  }

  public static function na() : Value {
    return VNA;
  }

  public static function nm() : Value {
    return VNM;
  }

  @:to
  public function toFloat() : Float {
    return switch this {
      case VFloat(v) : v;
      case VInt(v) : v;
      case VBool(v) : throw new Error('cannot convert Bool to Float');
      case VString(v) : throw new Error('cannot convert String to Float');
      case VNA : throw new Error('cannot convert NA to Float');
      case VNM : throw new Error('cannot convert NM to Float');
    };
  }

  @:to
  public function toInt() : Int {
    return switch this {
      case VFloat(v) : Std.int(v);
      case VInt(v) : v;
      case VBool(v) : throw new Error('cannot convert Bool to Int');
      case VString(v) : throw new Error('cannot convert String to Int');
      case VNA : throw new Error('cannot convert NA to Int');
      case VNM : throw new Error('cannot convert NM to Int');
    };
  }

  @:to
  public function toBool() : Bool {
    return switch this {
      case VFloat(v) : v != 0.0;
      case VInt(v) : v != 0;
      case VBool(v) : v;
      case VString(v) : v.toLowerCase() == TRUE_STRING;
      case VNA : throw new Error('cannot convert NA to Bool');
      case VNM : throw new Error('cannot convert NM to Bool');
    };
  }

  @:to
  public function toString() : String {
    return switch this {
      case VFloat(v) : Std.string(v);
      case VInt(v) : Std.string(v);
      case VBool(v) : v ? TRUE_STRING : FALSE_STRING;
      case VString(v) : v;
      case VNA : NA_STRING.toUpperCase();
      case VNM : NM_STRING.toUpperCase();
    };
  }

  public function toDynamic() : Dynamic {
    return switch this {
      case VFloat(v) : v;
      case VInt(v) : v;
      case VBool(v) : v;
      case VString(v) : v;
      case VNA : null;
      case VNM : null;
    };
  }

  public function isInt(?test : Int) : Bool {
    return switch this {
      case VInt(v) : test == null || test == v;
      case _ : false;
    };
  }

  public function isFloat(?test : Float) : Bool {
    return switch this {
      case VFloat(v) : test == null || test == v;
      case _ : false;
    };
  }

  public function isBool(?test : Bool) : Bool {
    return switch this {
      case VBool(v) : test == null || test == v;
      case _ : false;
    };
  }

  public function isString(?test : String) : Bool {
    return switch this {
      case VString(v) : test == null || test == v;
      case _ : false;
    };
  }

  public function isNumeric(?test : Float) : Bool {
    return switch this {
      case VFloat(v) : test == null || test == v;
      case VInt(v) : test == null || test == v;
      case _: false;
    };
  }

  public function isNA() : Bool {
    return switch this {
      case VNA: true;
      case _: false;
    };
  }

  public function isNM() : Bool {
    return switch this {
      case VNM: true;
      case _: false;
    };
  }

  public function isNone() : Bool {
    return isNA() || isNM();
  }

  public function equals(other : Value) {
    return switch [this, other.toValueType()] {
      case [VFloat(value), VFloat(other)] : value == other;
      case [VFloat(value), VInt(other)] : value == other;

      case [VInt(value), VInt(other)] : value == other;
      case [VInt(value), VFloat(other)] : value == Std.int(other);

      case [VBool(value), VBool(other)] : value == other;
      case [VString(value), VString(other)] : value == other;
      case [VNA, VNA] : true;
      case [VNM, VNM] : true;

      case [_, _] : false;
    };
  }

  public static function stringIsFloat(input : String) : Bool {
    if (input.isEmpty()) return false;
    return ~/^[+-]?(?:\d*)(?:\.\d*)?(?:[eE][+-]?\d+)?$/.match(input);
  }

  public static function stringIsInt(input : String) : Bool {
    return ~/^\d+$/.match(input);
  }
}
