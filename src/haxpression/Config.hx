package haxpression;

class Config {
  // Set to true to enable pseudo-immutable expressions, that are deep-cloned
  // before any modification is applied.  When false, no expressions are modified
  // in-place, which is faster for now.
  public static var useCloneForExpressions(default, default) = false;

  // Set to true to enable pseudo-immutable expression groups, that are deep-cloned
  // before any modification is applied.  When false, no expression groups are modified
  // in-place, which is faster for now.
  public static var useCloneForExpressionGroups(default, default) = false;
}
