/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.functions;


///
struct Function {
  import gooey.css.values : Value;

  ///
  string name;
  ///
  const(Value)[] parameters;

  /// Whether all of this function's parameters are of tpe `T`.
  bool parametersAreOf(T)() @property const {
    import std.algorithm : all;
    return this.parameters.all!(param => typeid(T).isBaseOf(param.classinfo));
  }
}
