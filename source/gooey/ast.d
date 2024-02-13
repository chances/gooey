/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.ast;

import std.exception : enforce;

import gooey.parsers : Position;

///
abstract class Node {
  /// Source position of this node.
  const Position* sourcePosition;

  /// Instantiate a new AST node.
  ///
  /// Params:
  ///   sourcePosition = Source position of this node. Defaults to `null`.
  this(const Position* sourcePosition = null) {
    this.sourcePosition = sourcePosition;
  }
}

///
interface Parsable(T) {
  ///
  static T parse(string input);
}

/// Thrown when a parser encounters a syntax error.
class SyntaxError : Exception {
  private const Position* sourcePosition;

  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.sourcePosition = null;
  }
  this(const Node node, string msg = null, string file = __FILE__, size_t line = __LINE__) {
    super(msg, file, line);
    this.sourcePosition = node.sourcePosition;
  }
}

string enforceContentful(string input) {
  if(input is null || input.length == 0) throw new SyntaxError("Expected non-null, non-empty input!");
  return input;
}
