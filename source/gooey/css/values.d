/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.values;

import pegged.peg : Position;
import std.conv : to;
import std.typecons : Flag, No;

import gooey.ast;

/// An abstract CSS value.
/// See_Also: $(UL
///   $(LI `Keyword`)
///   $(LI `Length`)
///   $(LI `Color`)
/// )
abstract class Value : Node {
  this(const Position* sourcePosition = null) {
    super(sourcePosition);
  }

  static const(Value) parse(string input) {
    import gooey.css.parser : CSS, GetName;
    import std.algorithm : any, endsWith, equal, map, stripLeft, stripRight;
    import std.array : array, join;
    import std.ascii : isDigit;
    import std.conv : parse;
    import std.string : format;
    import std.traits : EnumMembers;

    auto term = CSS.term(input.enforceContentful()).decimate!CSS();
    if (!term.successful) throw new SyntaxError(term);
    assert(term.isNamed(&CSS.term) && term.children.length > 0);

    if (term.firstLeaf.isNamed(&CSS.string_)) return new String(term.match());
    if (term.firstLeaf.isNamed(&CSS.identifier)) {
      auto keyword = term.match();
      if (colors.keys.any!(color => color.equal(keyword))()) return colors[keyword];
      return new Keyword(keyword);
    }

    auto number = term.match();
    if (term.firstLeaf.isNamed(&CSS.number)) return new Length(parse!double(number));

    assert([EnumMembers!Unit].map!(unit => unit.notation()).any!(unit => number.endsWith(unit))());
    auto value = number.stripRight!(c => !c.isDigit && c != '.')();
    assert(value.length != number.length);
    return new Length(
      parse!double(value),
      parseUnit(number.stripLeft!(c => c.isDigit || c == '.')())
    );

    assert(0, "Unimplemented");
  }

  float pixels() @property const {
    if (typeid(Length).isBaseOf(this.classinfo) && this.to!(const Length).unit == Unit.pixels)
      return this.to!(const Length).value;
    // TODO: Other maths to convert other Length unit values to pixels
    return 0f;
  }

  /// Convert this value to its CSS representation.
  abstract string toCSS() @property const;
}

unittest {
  assert(new Length(-4, Unit.pixels).pixels == -4);
}

/// Unit of measurement for a <a href="https://drafts.csswg.org/css2/#length-units">CSS Length</a>.
/// See_Also: <a href="https://drafts.csswg.org/css2/#length-units">Lengths</a> - CSS 2 Specification
enum Unit {
  ///
  unitless,
  /// Relative to another value, for example a length. Each property that allows percentages also defines the value to
  /// which the percentage refers.
  percentage,
  /// The computed value of the `font-size` property of the element on which it is used.
  /// See_Also: <a href="https://drafts.csswg.org/css2/#propdef-font-size">`font-size` Property</a> - CSS 2 Specification
  em,
  /// Often equal to the height of the lowercase "x". However, an ex is defined even for fonts that do not contain an "x".
  ex,
  /// The computed value of the `font-size` property of the document on which it is used.
  rem,
  /// Equal to 2.54 centimeters.
  inches,
  ///
  centimeters,
  ///
  millimeters,
  /// Equal to 1/72nd of 1 inch.
  points,
  /// Equal to 12pt.
  picas,
  /// Equal to 0.75pt.
  pixels,
  ///
  degrees,
  ///
  radians,
}

///
string getName(Unit unit) @property {
  switch (unit) {
    case Unit.unitless:
      return "Unitless";
    case Unit.percentage:
      return "Percentage";
    case Unit.em:
      return "Ems";
    case Unit.ex:
      return "x-Height";
    case Unit.rem:
      return "Relative Ems";
    case Unit.inches:
      return "Inches";
    case Unit.centimeters:
      return "Centimeters";
    case Unit.millimeters:
      return "Millimeters";
    case Unit.points:
      return "Points";
    case Unit.picas:
      return "Picas";
    case Unit.pixels:
      return "Pixels";
    case Unit.degrees:
      return "Degrees";
    case Unit.radians:
      return "Radians";
    default:
      assert(0, "Unreachable code!");
  }
}

///
string notation(Unit unit) @property {
  switch (unit) {
    case Unit.unitless:
      return "";
    case Unit.percentage:
      return "%";
    case Unit.em:
      return "em";
    case Unit.ex:
      return "ex";
    case Unit.rem:
      return "rem";
    case Unit.inches:
      return "in";
    case Unit.centimeters:
      return "cm";
    case Unit.millimeters:
      return "mm";
    case Unit.points:
      return "pt";
    case Unit.picas:
      return "pc";
    case Unit.pixels:
      return "px";
    case Unit.degrees:
      return "deg";
    case Unit.radians:
      return "rad";
    default:
      assert(0, "Unreachable code!");
  }
}

/// Parse a CSS unit given its `notation`.
Unit parseUnit(string notation) {
  import std.algorithm : equal;

  foreach (unit; Unit.min..Unit.max) {
    if (unit.notation().equal(notation)) return unit;
  }
  return Unit.unitless;
}

unittest {
  import std.algorithm : equal;

  assert(parseUnit("") == Unit.unitless);
  assert(parseUnit("foo") == Unit.unitless);
  assert(parseUnit("ex").getName().equal("x-Height"));
  assert(parseUnit("in") == Unit.inches);
  assert(parseUnit("in").getName().equal("Inches"));
  assert(parseUnit("cm") == Unit.centimeters);
  assert(parseUnit("cm").getName().equal("Centimeters"));
  assert(parseUnit("mm") == Unit.millimeters);
  assert(parseUnit("mm").getName().equal("Millimeters"));
  assert(parseUnit("pc") == Unit.picas);
  assert(parseUnit("pc").getName().equal("Picas"));
}

/// A distnace measurement.
/// See_Also: <a href="https://drafts.csswg.org/css2/#length-units">Lengths</a> - CSS 2 Specification
class Length : Value, Parsable!Length {
  /// Unit of measurement of this length's `value`.
  /// See_Also: <a href="https://drafts.csswg.org/css2/#length-units">Lengths</a> - CSS 2 Specification
  const Unit unit;
  ///
  const double value;

  ///
  this(double value, Unit unit = Unit.unitless, const Position* sourcePosition = null) {
    super(sourcePosition);
    this.value = value;
    this.unit = unit;
  }

  ///
  static Length zero(Unit unit) {
    return new Length(0, unit);
  }

  /// See_Also: `Value.parse`
  static const(Length) parse(string input) {
    return Value.parse(input).to!(const Length);
  }

  ///
  override string toCSS() @property const {
    import std.conv : text;
    import std.string : format, stripRight;
    return text(value) ~ unit.notation();
  }

  ///
  override string toString() const {
    import std.conv : text;
    import std.string : format, stripRight;
    const result = value == 0
      ? format!"0 %s"(unit.getName())
      : value % 1 == 0
        ? format!"%d %s"(value.to!long, unit.getName())
          // Strip trailing zeroes from printed floating point lengths
        : format!"%s %s"(text(value).stripRight("0"), unit.getName());
    return unit == Unit.unitless ? result : format!"%s (%s)"(result, unit.notation());
  }
}

unittest {
  import std.algorithm : equal;

  const zero = Length.zero(Unit.unitless);
  assert(zero.toString().equal("0 Unitless"), "Got " ~ zero.toString());

  assert(new Length(72, Unit.percentage).toString().equal("72 Percentage (%)"));
  assert(new Length(840, Unit.em).toString().equal("840 Ems (em)"));
  assert(new Length(1.5, Unit.rem).toString().equal("1.5 Relative Ems (rem)"));
  assert(new Length(12, Unit.points).toString().equal("12 Points (pt)"));
  assert(new Length(-4, Unit.pixels).toString().equal("-4 Pixels (px)"));
  assert(new Length(12, Unit.degrees).toString().equal("12 Degrees (deg)"));
  import std.math : PI;
  assert(new Length(PI, Unit.radians).toString().equal("3.14159 Radians (rad)"));

  auto number = Length.parse("45.5");
  assert(typeid(number).isBaseOf(number.classinfo));
  assert(number.value == 45.5);
  assert(number.unit == Unit.unitless);

  const length = Length.parse("12px");
  assert(typeid(Length).isBaseOf(length.classinfo));
  assert(length.value == 12);
  assert(length.unit == Unit.pixels);
  assert(length.toCSS().equal("12px"));
}

/// A string of text.
/// See_Also: <a href="https://drafts.csswg.org/css2/#strings">Strings</a> - CSS 2 Specification
class String : Value {
  ///
  const string value;

  ///
  this(string value, const Position* sourcePosition = null) {
    super(sourcePosition);
    this.value = value;
  }

  /// See_Also: `Value.parse`
  static const(String) parse(string input) {
    return Value.parse(input).to!(const String);
  }

  ///
  override string toCSS() @property const {
    return toCSS(No.singleQuotes);
  }
  string toCSS(Flag!"singleQuotes" singleQuotes) @property const {
    import std.string : replace;

    const quote = singleQuotes ? "'" : "\"";
    return quote ~ value.replace(quote, "\\" ~ quote) ~ quote;
  }

  ///
  override string toString() const {
    return this.toCSS();
  }
}

unittest {
  import std.algorithm : equal;

  auto foobar = String.parse("'foobar'");
  assert(foobar.value.equal("foobar"));
  assert(foobar.toCSS.equal("\"foobar\""));
}

/// A reserved intentifier.
/// See_Also: https://drafts.csswg.org/css2/#keywords
class Keyword : Value {
  ///
  const string value;

  ///
  this(string value, const Position* sourcePosition = null) {
    super(sourcePosition);
    this.value = value;
  }

  ///
  static const auto_ = new Keyword("auto");

  /// See_Also: `Value.parse`
  static const(Keyword) parse(string input) {
    return Value.parse(input).to!(const Keyword);
  }

  ///
  override string toCSS() @property const {
    return typeid(Color).isBaseOf(this.classinfo) ? this.to!(const Color).toCSS() : value;
  }

  ///
  override string toString() const {
    return this.toCSS();
  }

  override bool opEquals(Object o) const {
    if (o is this) return true;
    if (o is null) return false;
    if (typeid(o) != this.classinfo) return false;
    return o.to!Keyword.toHash() == this.toHash();
  }

  override size_t toHash() const @nogc @safe pure nothrow {
    return hashOf(value);
  }
}

unittest {
  import std.algorithm : equal;

  assert(Keyword.auto_ == new Keyword("auto"));
  assert(Keyword.auto_ == Keyword.auto_);
  assert(Keyword.auto_ !is null);
  assert(Keyword.auto_ != new Length(0));

  auto keyword = new Keyword("orange");
  assert(Keyword.auto_ != keyword);

  assert(Keyword.parse("inset").value.equal("inset"));
}

/// Either a keyword or a numerical RGB(A) value.
/// See_Also: https://drafts.csswg.org/css2/#color-units
class Color : Keyword {
  /// Red component of this color.
  const ubyte r;
  /// Green component of this color.
  const ubyte g;
  /// Blue component of this color.
  const ubyte b;
  /// Alpha component of this color. `0` is fully transparent. `255`/`0xFF` is fully opaque;
  const ubyte a;

  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-aqua
  static const aqua = new Color("aqua", 0, 0xFF, 0xFF);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-black
  static const black = new Color("black", 0, 0, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-blue
  static const blue = new Color("blue", 0, 0, 0xFF);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-fuchsia
  static const fuchsia = new Color("fuchsia", 0xFF, 0, 0xFF);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-gray
  static const gray = new Color("gray", 0x80, 0x80, 0x80);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-green
  static const green = new Color("green", 0, 0x80, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-lime
  static const lime = new Color("lime", 0, 0xFF, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-maroon
  static const maroon = new Color("maroon", 0x80, 0, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-navy
  static const navy = new Color("navy", 0, 0, 0x80);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-olive
  static const olive = new Color("olive", 0, 0x80, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-orange
  static const orange = new Color("orange", 0xFF, 0xA5, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-purple
  static const purple = new Color("purple", 0x80, 0, 0x80);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-red
  static const red = new Color("red", 0xFF, 0, 0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-silver
  static const silver = new Color("silver", 0xC0, 0xC0, 0xC0);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-teal
  static const teal = new Color("teal", 0, 0x80, 0x80);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-white
  static const white = new Color("white", 0xFF, 0xFF, 0xFF);
  /// See_Also: https://drafts.csswg.org/css2/#valdef-color-yellow
  static const yellow = new Color("yellow", 0xFF, 0xFF, 0);

  /// Instantiate a reserved color `Keyword`.
  this(string keyword, int r, int g, int b, int a = 0, const Position* sourcePosition = null) {
    this(keyword, cast(byte) r, cast(byte) g, cast(byte) b, cast(byte) a, sourcePosition);
  }
  /// Instantiate a reserved color `Keyword`.
  this(string keyword, byte r, byte g, byte b, byte a = 0, const Position* sourcePosition = null) {
    super(keyword, sourcePosition);
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  ///
  this(int r, int g, int b, int a = 0, const Position* sourcePosition = null) {
    this(cast(byte) r, cast(byte) g, cast(byte) b, cast(byte) a, sourcePosition);
  }
  ///
  this(byte r, byte g, byte b, byte a = 0, const Position* sourcePosition = null) {
    super(null, sourcePosition);
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  /// See_Also: `Value.parse`
  static const(Color) parse(string input) {
    return Value.parse(input).to!(const Color);
  }

  override string toCSS() @property const {
    import std.string : format;
    if (a > 0) {
      import std.math : round;
      return format!"rgba(%d,%d,%d,%d%%)"(r, g, b, round(a.to!int / 255 * 100).to!int);
    }
    return "#" ~ format!"%X"((r << 16) + (g << 8) + b);
  }
}

///
auto colors() {
  return [
    __traits(identifier, Color.aqua): Color.aqua,
    __traits(identifier, Color.black): Color.black,
    __traits(identifier, Color.blue): Color.blue,
    __traits(identifier, Color.fuchsia): Color.fuchsia,
    __traits(identifier, Color.gray): Color.gray,
    __traits(identifier, Color.green): Color.green,
    __traits(identifier, Color.lime): Color.lime,
    __traits(identifier, Color.maroon): Color.maroon,
    __traits(identifier, Color.navy): Color.navy,
    __traits(identifier, Color.olive): Color.olive,
    __traits(identifier, Color.orange): Color.orange,
    __traits(identifier, Color.purple): Color.purple,
    __traits(identifier, Color.red): Color.red,
    __traits(identifier, Color.silver): Color.silver,
    __traits(identifier, Color.teal): Color.teal,
    __traits(identifier, Color.white): Color.white,
    __traits(identifier, Color.yellow): Color.yellow
  ];
}

unittest {
  import std.algorithm : equal;

  assert(colors["red"].toCSS.equal("#FF0000"));
  assert(Color.parse("red").toCSS.equal("#FF0000"));
}
