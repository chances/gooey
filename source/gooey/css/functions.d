/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.functions;

import pegged.peg : ParseTree, Position, position;

import gooey.ast;
import gooey.css.values : Value;

///
struct Function {
  ///
  string name;
  ///
  const(Value)[] parameters;

  package (gooey.css) static const(Function) parse(ParseTree term) {
    import gooey.css.parser : CSS;
    import std.algorithm : all, filter, joiner, map, splitter;
    import std.array : array;
    import std.uni : isWhite;

    assert(term.isNamed(&CSS.function_) && term.children.length > 0);
    auto name = term.firstChild.match();
    auto params = term.lastChild.children
      .splitter!(node => node.match() == ",").joiner
      .filter!(node => node.match().all!(c => !c.isWhite))
      // TODO: Refactor away redundant parse and parse a CSS value given the node
      .map!(node => Value.parse(node.match()))
      .array;
    return Function(name, params);
  }

  /// Whether all of this function's parameters are of tpe `T`.
  bool parametersAreOf(T)() @property const {
    import std.algorithm : all;
    return this.parameters.all!(param => typeid(T).isBaseOf(param.classinfo));
  }
}
