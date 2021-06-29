module gooey.css.values;

import std.conv : to;

abstract class Value {
  float pixels() @property const {
    if (typeid(Length).isBaseOf(this.classinfo) && this.to!(const Length).unit == Unit.pixels)
      return this.to!(const Length).value;
    // TODO: Other maths to convert other Length unit values to pixels
    return 0f;
  }
}

enum Unit {
  unitless,
  percentage,
  ems,
  rems,
  points,
  pixels,
  degrees,
  radians,
}

string getName(Unit unit) @property {
  switch (unit) {
    case Unit.unitless:
      return "Unitless";
    case Unit.percentage:
      return "Percentage";
    case Unit.ems:
      return "Ems";
    case Unit.rems:
      return "Relative Ems";
    case Unit.points:
      return "Points";
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
    case Unit.ems:
      return "em";
    case Unit.rems:
      return "rem";
    case Unit.points:
      return "pt";
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

class Length : Value {
  const Unit unit;
  const double value;

  this(double value, Unit unit = Unit.unitless) {
    this.value = value;
    this.unit = unit;
  }

  static Length zero(Unit unit) {
    return new Length(0, unit);
  }

  override string toString() const {
    import std.string : format;
    if (unit == Unit.unitless) return format!"%f %s"(value, unit.getName());
    return format!"%f %s (%s)"(value, unit.getName(), unit.notation());
  }
}

unittest {
  const zero = Length.zero(Unit.unitless);
  assert(zero.toString() == "0 Unitless");

  const length = new Length(12, Unit.pixels);
  assert(length.toString() == "12 Pixels (px)");
}

class String : Value {
  const string value;

  this(string value) {
    this.value = value;
  }

  override string toString() const {
    return "\"" ~ value ~ "\"";
  }
}

class Keyword : Value {
  const string value;

  this(string value) {
    this.value = value;
  }

  static const auto_ = new Keyword("auto");

  override string toString() const {
    return value;
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
  assert(Keyword.auto_ != null);
  assert(Keyword.auto_ != new Length(0));

  keyword = new Keyword("orange");
  assert(Keyword.auto_ != keyword);
}
