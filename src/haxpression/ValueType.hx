package haxpression;

enum ValueType {
  VFloat(v : Float);
  VInt(v : Int);
  VBool(v : Bool);
  VString(v : String);
  VNA; // not available
  VNM; // not meaningful (based on domain-specific rules regarding meaning)
}
