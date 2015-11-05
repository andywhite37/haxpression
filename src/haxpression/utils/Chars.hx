package haxpression.utils;

using StringTools;
using haxpression.utils.Arrays;

class Chars {
  public static var PERIOD(default, never) = ".";
  public static var COMMA(default, never) = ",";
  public static var SINGLE_QUOTE(default, never) = "'";
  public static var DOUBLE_QUOTE(default, never) = '"';
  public static var EXCLAMATION_POINT(default, never) = "!";
  public static var OPEN_PAREN(default, never) = "(";
  public static var CLOSE_PAREN(default, never) = ")";
  public static var OPEN_BRACKET(default, never) = "[";
  public static var CLOSE_BRACKET(default, never) = "]";
  public static var QUESTION_MARK(default, never) = "?";
  public static var SEMICOLON(default, never) = ";";
  public static var COLON(default, never) = ":";

  public static var TAB_CODE(default, never) = 9;
  public static var LF_CODE(default, never) = 10;
  public static var CR_CODE(default, never) = 13;
  public static var SPACE_CODE(default, never) = 32;
  public static var EXCLAMATION_POINT_CODE(default, never) = 33;
  public static var DOUBLE_QUOTE_CODE(default, never) = 34;
  public static var DOLLAR_CODE(default, never) = 36;
  public static var SINGLE_QUOTE_CODE(default, never) = 39;
  public static var OPEN_PAREN_CODE(default, never) = 40;
  public static var CLOSE_PAREN_CODE(default, never) = 41;
  public static var COMMA_CODE(default, never) = 44;
  public static var PERIOD_CODE(default, never) = 46;
  public static var COLON_CODE(default, never) = 58;
  public static var SEMICOLON_CODE(default, never) = 59;
  public static var QUESTION_MARK_CODE(default, never) = 63;
  public static var OPEN_BRACKET_CODE(default, never) = 91;
  public static var CLOSE_BRACKET_CODE(default, never) = 93;
  public static var UNDERSCORE_CODE(default, never) = 95;

  // allow for other characters starting/inside identifiers
  public static var OTHER_IDENTIFIER_START_CODES = [];
  public static var OTHER_IDENTIFIER_PART_CODES = [EXCLAMATION_POINT_CODE, DOLLAR_CODE, COLON_CODE];

  public static function isDecimalDigit(charCode : Int) : Bool {
    return charCode >= 48 && charCode <= 57;
  }

  public static function isUpperCaseLetter(charCode : Int) : Bool {
    return charCode >= 65 && charCode <= 90;
  }

  public static function isLowerCaseLetter(charCode : Int) : Bool {
    return charCode >= 97 && charCode <= 122;
  }

  public static function isIdentifierStart(charCode : Int) : Bool {
    return charCode == DOLLAR_CODE ||
      charCode == UNDERSCORE_CODE ||
      isUpperCaseLetter(charCode) ||
      isLowerCaseLetter(charCode) ||
      OTHER_IDENTIFIER_START_CODES.contains(charCode);
  }

  public static function isIdentifierPart(charCode : Int) : Bool {
    return isIdentifierStart(charCode) ||
      isDecimalDigit(charCode) ||
      OTHER_IDENTIFIER_PART_CODES.contains(charCode);
  }

  public static function isWhiteSpace(charCode : Int) : Bool {
    return charCode == TAB_CODE ||
      charCode == LF_CODE ||
      charCode == CR_CODE ||
      charCode == SPACE_CODE;
  }
}
