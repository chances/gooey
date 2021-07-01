/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.selectors;

import pegged.peg : ParseTree, Position, position;
import std.algorithm : cmp;
import std.conv : to;

import gooey.ast;
import gooey.css : SyntaxError;

/// See_Also: <a href="https://drafts.csswg.org/css2/#specificity">Calculating a selector’s specificity</a> - CSS 2 Specification
struct Specificity {
  /// Whether a `Selector` selects for an element.
  const uint elementParts;
  /// Whether a `Selector` selects for an ID.
  const uint idParts;
  /// Number of selected class names selected by a `Selector`.
  const uint classParts;

  /// Total calculated specificity weight of a `Selector`.
  auto total() @property const {
    return elementParts + idParts + classParts;
  }

  int opCmp(ref const Specificity s) const {
    return s.total - this.total;
  }

  bool opEquals()(auto ref const Specificity s) const {
    return s.toHash() == this.toHash();
  }

  size_t toHash() const @nogc @safe pure nothrow {
    return hashOf(total);
  }
}

/// An abstract CSS selector.
/// SeeAlso: `SimpleSelector`
abstract class Selector : Node {
  /// Specificity weight of this selector.
  const Specificity specificity;

  ///
  this(Specificity specificity, const Position* position = null) {
    super(position);
    this.specificity = specificity;
  }

  /// Parse a selector given a string `input`.
  static Selector parse(string input) {
    import gooey.css.parser : CSS, GetName;
    import std.array : join;
    import std.functional : toDelegate;

    const ast = CSS.selector(input.enforceContentful()).decimate!CSS();
    if (!ast.successful) throw new SyntaxError(ast);

    assert(ast.name.cmp(CSS.selector(GetName())) == 0);
    const selector = ast.enforceChildNamed(&CSS.simpleSelector);
    string id = null;
    string elementName = null;
    string[] classes;
    foreach (node; selector.children) {
      if (node.isNamed(&CSS.hash)) id = node.matches[1..$].join();
      else if (node.isNamed(&CSS.elementName)) elementName = node.matches.join();
      else if (node.isNamed(&CSS.class_)) classes ~= node.matches[1..$].join();
    }

    const position = position(ast);
    return new SimpleSelector(elementName, id, classes, &position);
  }

  override int opCmp(const Object o) const {
    if (o is this) return 0;
    if (o is null) return 1;
    if (typeid(Selector).isBaseOf(typeid(o)) == false) return 1;
    return o.to!(const Selector).specificity.opCmp(this.specificity);
  }

  bool opEquals()(auto ref const Selector s) const {
    return this.opCmp(s) == 0;
  }

  override size_t toHash() const @nogc @safe pure nothrow {
    return hashOf(specificity.total);
  }

  /// Whether this selector matches the given `className`.
  abstract bool hasClass(string className) const;
}

unittest {
  import std.algorithm : equal;
  import std.exception : assertNotThrown, assertThrown;

  assertThrown!SyntaxError(Selector.parse("0"));
  assertNotThrown!SyntaxError(assert(Selector.parse("*").to!SimpleSelector.isUniversalSelector));

  auto div = assertNotThrown!SyntaxError(Selector.parse("div"));
  assert(typeid(SimpleSelector).isBaseOf(div.classinfo));
  assert(div.to!SimpleSelector.elementName.cmp("div") == 0);

  div = assertNotThrown!SyntaxError(Selector.parse("div.hidden"));
  assert(div.to!SimpleSelector.elementName.cmp("div") == 0);
  assert(div.to!SimpleSelector.classes.equal(["hidden"]));

  auto widget = assertNotThrown!SyntaxError(Selector.parse("#myWidget.hidden"));
  assert(widget.to!SimpleSelector.id.cmp("myWidget") == 0);
  assert(widget.to!SimpleSelector.classes.equal(["hidden"]));
}

// TODO: The elements of the document tree that match a selector are called subjects.

/// Any combination of one <a href="https://drafts.csswg.org/css2/#type-selectors">type selector</a> or
/// <a href="https://drafts.csswg.org/css2/#universal-selector">universal selector</a> including zero or more
/// <a href="https://drafts.csswg.org/css2/#attribute-selectors">attribute selectors</a>, ID selectors, or
/// pseudo-classes.
///
/// The simple selector matches if all of its components match.
/// See_Also: https://drafts.csswg.org/css2/#simple-selector
class SimpleSelector : Selector {
  ///
  const string elementName;
  ///
  const string id;
  ///
  const string[] classes;

  ///
  this(string[] classes, ParseTree* node = null) { this(null, null, classes); }
  ///
  this(string elementName, string id, string[] classes, const Position* position = null) {
    super(
      Specificity(
        elementName is null ? 0 : 1,
        id is null ? 0 : 1,
        classes.length.to!uint
      ),
      position
    );
    this.elementName = elementName;
    this.id = id;
    this.classes = classes;
  }

  /// Instantiate a new simple selector given an element's name.
  static fromTag(string elementName) {
    return new SimpleSelector(elementName, null, new string[0]);
  }

  /// Instantiate a new simple selector given an element's ID.
  static fromId(string id) {
    return new SimpleSelector(null, id, new string[0]);
  }

  /// Whether this is the universal selector, i.e. it matches any single element in the document.
  /// See_Also: https://drafts.csswg.org/css2/#universal-selector
  bool isUniversalSelector() @property const {
    return this.elementName == "*";
  }

  /// Whether this selector matches the given `className`.
  override bool hasClass(string className) const {
    import std.algorithm : any;
    import std.uni : icmp;
    return this.classes.any!(extantClassName => extantClassName.icmp(className) == 0);
  }
}

unittest {
  import std.algorithm : cmp;

  assert(SimpleSelector.fromTag("*").isUniversalSelector);

  assert(SimpleSelector.fromId("usernameField").id.cmp("usernameField") == 0);

  const anchorSelector = SimpleSelector.fromTag("a");
  assert(hashOf(anchorSelector.elementName) == hashOf("a"));
  assert(anchorSelector.hasClass("hidden") == false);

  string[] classes = ["navbar", "hidden"];
  const hiddenNavbarSelector = new SimpleSelector(classes);
  assert( hiddenNavbarSelector.hasClass("navbar"));
  assert( hiddenNavbarSelector.hasClass("hidden"));
  assert(!hiddenNavbarSelector.hasClass("shake"));

  assert(anchorSelector < hiddenNavbarSelector);
  assert(anchorSelector.toHash() != hiddenNavbarSelector.toHash());
  assert(anchorSelector.specificity != hiddenNavbarSelector.specificity);
}
