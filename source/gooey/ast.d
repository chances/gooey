module gooey.ast;

import pegged.peg : GetName, ParseTree, Position, position;
import std.exception : enforce;

string enforceContentful(string input) {
  if(input is null || input.length == 0) throw new SyntaxError("Expected non-null, non-empty input!");
  return input;
}

/// Simplify a parsed AST.
ParseTree decimate(T)(ParseTree node) {
  auto simplifiedAst = T.decimateTree(node);
  debug {
    import std.array : join;
    import std.stdio : writeln;

    writeln(node.successful ? simplifiedAst.toString() : [node.name, node.failMsg()].join(": "));
  }
  return simplifiedAst;
}

abstract class Node {
  const Position* sourcePosition;

  /// Instantiate a new AST node.
  ///
  /// Params:
  ///   sourcePosition = Source position of this node. Defaults to `null`.
  this(const Position* sourcePosition = null) {
    this.sourcePosition = sourcePosition;
  }
}

/// Thrown when a parser encounters a syntax error.
class SyntaxError : Exception {
  private const Position* sourcePosition;

  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.sourcePosition = null;
  }
  this(const ParseTree node, string msg = null, string file = __FILE__, size_t line = __LINE__) {
    super(msg is null ? node.failMsg() : msg, file, line);
    const position = node.position();
    this.sourcePosition = &position;
  }
}

bool isNamed(const ParseTree node, string function(GetName _) rule) {
  import std.algorithm : cmp;
  return node.name.cmp(rule(GetName())) == 0;
}

/// Retreive a parsed node that is a child of the given `node` and has a name that matches the given `rule`.
/// Params:
///   node = Parent parser node.
///   rule = Parser rule returning the rule's name.
/// Returns: A parsed node with the resolved name that is a direct descendant of the given `node`.
/// Throws: `SyntaxError` when the named parsed node could not be found.
const(ParseTree) enforceChildNamed(const ParseTree node, string function(GetName _) rule) {
  import std.algorithm : joiner, map, splitter;
  import std.array : array, join;
  import std.string : format;

  const ruleName = rule(GetName());
  foreach (child; node.children) {
    if (child.isNamed(rule)) return child;
  }
  throw new SyntaxError(node, format!"Expected `%s`, but got `%s`"(
    ruleName.splitter(".").joiner(" ").array,
    node.children.length > 0 ? node.matches.join() : "end of file"
  ));
}

/// Format the given `node`'s name' for users.
/// Params:
///   node=
string prettyName(ParseTree node) {
  import std.algorithm : joiner, splitter;
  return prettyName(node.name);
}

/// Format the given generated pegged rule name for users.
/// Params:
///   name=
string prettyName(string name) {
  import std.algorithm : joiner, splitter;
  import std.array : array;
  import std.conv : to;

  return name.splitter(".").joiner(" ").array.to!string;
}

unittest {
  import std.algorithm : equal;
  assert("Foo".prettyName().equal("Foo"));
  assert("foobar".prettyName().equal("foobar"));

  assert(ParseTree("Foo.bar").prettyName().equal("Foo bar"));
}
