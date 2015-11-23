package haxpression.utils;

class Strings {
  public static function contains(target : String, test : String) : Bool {
    return target.indexOf(test) != -1;
  }

  public static function icontains(target : String, test : String) : Bool {
    return target.toLowerCase().indexOf(test.toLowerCase()) != -1;
  }

  public static function isEmpty(input : String) : Bool {
    return input == null || input == "";
  }

  public static function icompare(s1 : String, s2 : String) : Int {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();
    return if (s1 > s2) 1;
      else if (s1 < s2) -1;
      else 0;
  }
}
