module gooey.css.selectors;

import std.algorithm : cmp;
import std.conv : to;

import gooey.css : ParserException;

struct Specificity {
  const uint tagParts;
  const uint idParts;
  const uint classParts;

  auto total() @property const {
    return tagParts + idParts + classParts;
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

abstract class Selector {
  const Specificity specificity;

  this(Specificity specificity) {
    this.specificity = specificity;
  }

  static Selector parse(string input) {
    import gooey.css.parser : CSS, GetName;

    assert(input !is null && input.length > 0, "Expected non-null, non-empty input!");
    const ast = CSS.decimateTree(CSS.selector(input));
    if (!ast.successful) throw new ParserException(ast.failMsg());

    import std.stdio : writeln;
    writeln(ast.toString());

    assert(ast.name.cmp(CSS.selector(GetName())) == 0);
    if (ast.children[0].name.cmp(CSS.simpleSelector(GetName())) == 0) return SimpleSelector.fromTag(ast.matches[0]);

    assert(0, "Unimplemented");
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

  abstract bool hasClass(string className) const;
}

unittest {
  import std.exception : assertNotThrown, assertThrown;

  assertThrown!ParserException(Selector.parse("0"));
  assertNotThrown!ParserException(assert(Selector.parse("*").to!SimpleSelector.isUniversalSelector));

  string selectElement(string input) {
    const selector = Selector.parse(input);
    assert(typeid(SimpleSelector).isBaseOf(selector.classinfo));
    return selector.to!(const SimpleSelector).tagName;
  }

  assertNotThrown!ParserException(assert(selectElement("div").cmp("div") == 0));
}

class SimpleSelector : Selector {
  const string tagName;
  const string id;
  const string[] classes;

  this(string[] classes) { this(null, null, classes); }
  this(string tagName, string id, string[] classes) {
    super(Specificity(
      tagName is null ? 0 : 1,
      id is null ? 0 : 1,
      classes.length.to!uint)
    );
    this.tagName = tagName;
    this.id = id;
    this.classes = classes;
  }

  static fromTag(string tagName) {
    return new SimpleSelector(tagName, null, new string[0]);
  }

  static fromId(string id) {
    return new SimpleSelector(null, id, new string[0]);
  }

  /// Whether this is the universal selector, i.e.
  bool isUniversalSelector() @property const {
    return this.tagName == "*";
  }

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
  assert(hashOf(anchorSelector.tagName) == hashOf("a"));
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
