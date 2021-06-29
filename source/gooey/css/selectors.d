module gooey.css.selectors;

import std.conv : to;

struct Specificity {
  uint tagParts;
  uint idParts;
  uint classParts;
}

abstract class Selector {
  protected Specificity _specificity;

  this(Specificity specificity) {
    this._specificity = specificity;
  }

  auto specificity() @property const {
    return _specificity;
  }
}

class SimpleSelector : Selector {
  string _tagName;
  string _id;
  string[] _classes;

  this(string[] classes) { this(null, null, classes); }
  this(string tagName, string id, string[] classes) {
    super(Specificity(1, 1, classes.length.to!uint));
    this._tagName = tagName;
    this._id = id;
    this._classes = classes;
  }

  static fromTag(string tagName) {
    return new SimpleSelector(tagName, null, new string[0]);
  }

  static fromId(string id) {
    return new SimpleSelector(null, id, new string[0]);
  }

  auto tagName() @property const {
    return _tagName;
  }

  /// Whether this is the universal selector, i.e.
  bool isUniversalSelector() @property const {
    return this._tagName == "*";
  }

  auto id() @property const {
    return _id;
  }

  auto classes() @property const {
    return _classes;
  }
}
