package haxpression.utils;

class Strings {
  public static function contains(target : String, test : String) : Bool {
    return target.indexOf(test) != -1;
  }

  public static function icontains(target : String, test : String) : Bool {
    return target.toLowerCase().indexOf(test.toLowerCase()) != -1;
  }
}
