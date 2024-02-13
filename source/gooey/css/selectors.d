/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.selectors;

import std.conv : to;

import gooey.ast;
import gooey.css : SyntaxError;
import gooey.parsers;

/// See_Also: <a href="https://drafts.csswg.org/css2/#specificity">Calculating a selector’s specificity</a> - CSS 2 Specification
struct Specificity {
  /// Whether a `Declaration` is from a HTML `style` attribute.
  const bool fromStyleAttribute;
  /// Whether a `Selector` selects for an ID.
  const uint idParts;
  /// Number of selected class names selected by a `Selector`.
  const uint classParts;
  /// Whether a `Selector` selects for an element.
  const uint elementParts;

  /// Total calculated specificity weight of a `Selector`.
  auto total() @property const {
    const a = fromStyleAttribute ? 1000 : 0;
    const b = idParts * 100;
    const c = classParts * 10;
    return a + b + c + elementParts;
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
/// See_Also: `SimpleSelector`
abstract class Selector : Node, Parsable!Selector {
  /// Specificity weight of this selector.
  const Specificity specificity;

  ///
  this(Specificity specificity, const Position* position = null) {
    super(position);
    this.specificity = specificity;
  }

  /// Parse a selector given a string `input`.
  static Selector parse(string input) {
    import gooey.parsers : gooey_css_parse_selector, toString;
    import std.algorithm : equal;
    import std.array : join;

    const result = gooey_css_parse_selector(input.ptr, input.length);
    assert(0, (result.error is null ? result.value : result.error).toString);
    //const ast = result.value.deserialize;
    //if (!ast.successful) throw new SyntaxError(ast);

    string id = null;
    string elementName = null;
    string[] classes;
    string[] pseudoClasses;
    string[] attributes;

    const position = result.position;
    return new SimpleSelector(elementName, id, classes, pseudoClasses, attributes, &position);
  }

  override int opCmp(const Object o) const {
    if (o is this) return 0;
    if (o is null) return 1;
    if (typeid(Selector).isBaseOf(typeid(o)) == false) return 1;
    return o.to!(const Selector).specificity.opCmp(this.specificity);
  }

  bool opEquals()(auto ref const Selector s) const {
    // FIXME: Incorporate *all* of the selector's properties
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
  assert(div.to!SimpleSelector.elementName.equal("div"));

  div = assertNotThrown!SyntaxError(Selector.parse("div.hidden"));
  assert(div.to!SimpleSelector.elementName.equal("div"));
  assert(div.to!SimpleSelector.classes.equal(["hidden"]));

  auto widget = assertNotThrown!SyntaxError(Selector.parse("#myWidget.hidden"));
  assert(widget.to!SimpleSelector.id.equal("myWidget"));
  assert(widget.to!SimpleSelector.classes.equal(["hidden"]));

  auto hoveredButton = assertNotThrown!SyntaxError(Selector.parse("button:hover"));
  assert(hoveredButton.to!SimpleSelector.pseudoClasses.equal(["hover"]));
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
  const string[] pseudoClasses;
  ///
  const string[] attributes;

  ///
  this(string elementName, string[] classes = []) { this(elementName, null, classes, [], []); }
  ///
  this(string[] classes) { this(null, null, classes, [], []); }
  ///
  this(
    string elementName, string id, string[] classes = [], string[] pseudoClasses = [], string[] attributes = [],
    const Position* position = null
  ) {
    super(
      Specificity(
        false,
        elementName is null ? 0 : 1,
        id is null ? 0 : 1,
        classes.length.to!uint
      ),
      position
    );
    this.elementName = elementName;
    this.id = id;
    this.classes = classes;
    this.pseudoClasses = pseudoClasses;
    this.attributes = attributes;
  }

  /// Instantiate a new simple selector given an element's name.
  static fromTag(string elementName) {
    return new SimpleSelector(elementName);
  }

  /// Instantiate a new simple selector given an element's ID.
  static fromId(string id) {
    return new SimpleSelector(null, id);
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
  import std.algorithm : equal;

  assert(SimpleSelector.fromTag("*").isUniversalSelector);

  assert(SimpleSelector.fromId("usernameField").id.equal("usernameField"));

  const anchorSelector = SimpleSelector.fromTag("a");
  assert(hashOf(anchorSelector.elementName) == hashOf("a"));
  assert(anchorSelector.hasClass("hidden") == false);

  const navbarSelector = new SimpleSelector("nav", ["navbar"]);
  assert(navbarSelector.hasClass("navbar"));

  string[] classes = ["navbar", "hidden"];
  const hiddenNavbarSelector = new SimpleSelector("nav", classes);
  assert( hiddenNavbarSelector.hasClass("navbar"));
  assert( hiddenNavbarSelector.hasClass("hidden"));
  assert(!hiddenNavbarSelector.hasClass("shake"));

  assert(anchorSelector < hiddenNavbarSelector);
  assert(navbarSelector < hiddenNavbarSelector);
  assert(anchorSelector.toHash() != hiddenNavbarSelector.toHash());
  assert(anchorSelector.specificity != hiddenNavbarSelector.specificity);
}
