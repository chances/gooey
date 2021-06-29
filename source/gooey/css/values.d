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

unittest {
  assert(new Length(-4, Unit.pixels).pixels == -4);
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
    import std.string : format, stripRight;
    const result = value == 0
      ? format!"0 %s"(unit.getName())
      : value % 1 == 0
        ? format!"%d %s"(value.to!long, unit.getName())
          // Strip trailing zeroes from printed floating point lengths
        : format!"%s %s"(format!"%f"(value).stripRight("0"), unit.getName());
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
  assert(Keyword.auto_ !is null);
  assert(Keyword.auto_ != new Length(0));

  auto keyword = new Keyword("orange");
  assert(Keyword.auto_ != keyword);
}
