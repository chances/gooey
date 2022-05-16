/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom.attributes;

import gooey.dom.nodes : Node;
import std.algorithm : joiner;
import std.conv : to;

@safe:

///
struct Attribute {
  ///
  string name;
  ///
  string[] values;

  ///
  this(const string name, string[] values...) {
    this.name = name;
    this.values = values.dup;
  }
}

///
class Attr : Node {
  import gooey.dom : Document;
  import gooey.dom.elements : Element;

  private Attribute attribute_;
  ///
  static Element ownerElement;

  ///
  this(const string name, const Element owner, string[] values...) @trusted {
    this(name, null, cast(Element) owner, values);
  }
  ///
  this(const string name, Document owner, string[] values...) {
    this(name, owner, null, values);
  }
  ///
  this(const string name, Document owner, Element parent, string[] values...) {
    super(owner, parent);
    this.attribute_ = Attribute(name, [values.joiner(" ").to!string]);
    this.ownerElement = parent;
  }

  /// This attribute's name.
  string name() const @property {
    return this.attribute_.name;
  }
  /// This attribute's value.
  string value() const @property @trusted {
    auto values = cast(string[]) this.attribute_.values;
    return values.joiner(" ").to!string;
  }
  /// ditto
  void value(string value) @property {
    this.attribute_ = Attribute(this.name, [value]);
  }
}

/// Associative array of the given attributes' names and values.
string[][string] assocArray(const Attribute[] attributes) @property @trusted {
  import std.algorithm : filter, map;
  import std.array : array, assocArray;

  auto names = cast(string[]) attributes.map!(a => a.name).array;
  auto values = cast(string[][]) attributes.map!(a => a.values).array;
  return assocArray(names, values);
}

unittest {
  import std.algorithm : equal;
  import std.conv : text;

  const attrs = [Attribute("href", []), Attribute("src", ["smile.png"])];
  string[][string] expectation;
  expectation["href"] = [""];
  expectation["src"] = ["smile.png"];
  assert(
    attrs.assocArray["href"].length == 1,
    "Attribute `href` has " ~ attrs.assocArray["href"].length.text ~ " values: " ~ attrs.assocArray["href"].text
  );
  assert(attrs.assocArray["href"].equal(expectation["href"]));
  assert(attrs.assocArray["src"].equal(expectation["src"]));
}
