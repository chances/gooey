module gooey.parsers;

import gooey.ast;

public import css;
public import html;

string toString(const char* str) {
  import std.conv : castFrom, to;
  import std.string : format, fromStringz;

  return str.fromStringz.to!string;
}

string toString(const void* str) {
  import std.conv : castFrom, to;
  import std.string : format, fromStringz;

  return castFrom!(const void*).to!(const char*)(str).fromStringz.to!string;
}

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

  assert("Foo.bar".prettyName.equal("Foo bar"));
}
