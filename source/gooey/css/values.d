/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css.values;

import std.conv : to;
import std.typecons : Flag, No;

/// An abstract CSS value.
/// See_Also: $(UL
///   $(LI `Keyword`)
///   $(LI `Length`)
///   $(LI `Color`)
/// )
abstract class Value {
  float pixels() @property const {
    if (typeid(Length).isBaseOf(this.classinfo) && this.to!(const Length).unit == Unit.pixels)
      return this.to!(const Length).value;
    // TODO: Other maths to convert other Length unit values to pixels
    return 0f;
  }

  /// Convert this value to its CSS representation.
  abstract string toCSS() const;
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

string getName(Unit unit) @property {
  switch (unit) {
    case Unit.unitless:
      return "Unitless";
    case Unit.percentage:
      return "Percentage";
    case Unit.em:
      return "Ems";
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

string notation(Unit unit) @property {
  switch (unit) {
    case Unit.unitless:
      return "";
    case Unit.percentage:
      return "%";
    case Unit.em:
      return "em";
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

/// A distnace measurement.
/// See_Also: <a href="https://drafts.csswg.org/css2/#length-units">Lengths</a> - CSS 2 Specification
class Length : Value {
  /// Unit of measurement of this length's `value`.
  /// See_Also: <a href="https://drafts.csswg.org/css2/#length-units">Lengths</a> - CSS 2 Specification
  const Unit unit;
  ///
  const double value;

  ///
  this(double value, Unit unit = Unit.unitless) {
    this.value = value;
    this.unit = unit;
  }

  ///
  static Length zero(Unit unit) {
    return new Length(0, unit);
  }

  ///
  override string toCSS() const {
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
  const zero = Length.zero(Unit.unitless);
  assert(hashOf(zero.toString()) == hashOf("0 Unitless"), "Got " ~ zero.toString());

  assert(hashOf(new Length(72, Unit.percentage).toString()) == hashOf("72 Percentage (%)"));
  assert(hashOf(new Length(840, Unit.ems).toString()) == hashOf("840 Ems (em)"));
  assert(hashOf(new Length(1.5, Unit.rems).toString()) == hashOf("1.5 Relative Ems (rem)"));
  assert(hashOf(new Length(12, Unit.points).toString()) == hashOf("12 Points (pt)"));
  assert(hashOf(new Length(-4, Unit.pixels).toString()) == hashOf("-4 Pixels (px)"));
  assert(hashOf(new Length(12, Unit.degrees).toString()) == hashOf("12 Degrees (deg)"));
  import std.math : PI;
  assert(hashOf(new Length(PI, Unit.radians).toString()) == hashOf("3.141593 Radians (rad)"));
}

/// A string of text.
/// See_Also: <a href="https://drafts.csswg.org/css2/#strings">Strings</a> - CSS 2 Specification
class String : Value {
  ///
  const string value;

  ///
  this(string value) {
    this.value = value;
  }

  ///
  string toCSS(Flag!"singleQuotes" singleQuotes = No.singleQuotes) const {
    import std.string : replace;

    const quote = singleQuotes ? "'" : "\"";
    return quote ~ value.replace(quote, "\\" ~ quote) ~ quote;
  }

  ///
  override string toString() const {
    return this.toCSS();
  }
}

/// A reserved intentifier.
/// See_Also: https://drafts.csswg.org/css2/#keywords
class Keyword : Value {
  ///
  const string value;

  ///
  this(string value) {
    this.value = value;
  }

  ///
  static const auto_ = new Keyword("auto");

  ///
  override string toCSS() const {
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
  assert(Keyword.auto_ == new Keyword("auto"));
  assert(Keyword.auto_ == Keyword.auto_);
  assert(Keyword.auto_ !is null);
  assert(Keyword.auto_ != new Length(0));

  auto keyword = new Keyword("orange");
  assert(Keyword.auto_ != keyword);
}

/// Either a keyword or a numerical RGB(A) value.
/// See_Also: https://drafts.csswg.org/css2/#color-units
class Color : Keyword {
  /// Red component of this color.
  const byte r;
  /// Green component of this color.
  const byte g;
  /// Blue component of this color.
  const byte b;
  /// Alpha component of this color. `0` is fully transparent. `255`/`0xFF` is fully opaque;
  const byte a;

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
  this(string keyword, int r, int g, int b, int a = 0) {
    this(keyword, cast(byte) r, cast(byte) g, cast(byte) b, cast(byte) a);
  }
  /// Instantiate a reserved color `Keyword`.
  this(string keyword, byte r, byte g, byte b, byte a = 0) {
    super(keyword);
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  ///
  this(int r, int g, int b, int a = 0) {
    this(cast(byte) r, cast(byte) g, cast(byte) b, cast(byte) a);
  }
  ///
  this(byte r, byte g, byte b, byte a = 0) {
    super(null);
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
}
