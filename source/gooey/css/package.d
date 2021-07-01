/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.css;

public {
  import gooey.ast : SyntaxError;
  import gooey.css.parser;
  import gooey.css.selectors;
  import gooey.css.values;
}

///
struct Stylesheet {
  /// Set of style rules to apply to the subject of this stylesheet.
  RuleSet rules;

  /// Parse a stylesheet given an `input` string.
  /// Throws: `SyntaxError` when an irrecoverable syntax error is encournterd.
  Stylesheet parse(string input) {
    import gooey.ast : enforceContentful;

    try enforceContentful(input);
    catch (SyntaxError e) {
      if (input.length == 0) return Stylesheet([]);
      throw e;
    }

    assert(0, "Unimplemented");
  }
}

/// A set of `Rule`s.
alias RuleSet = Rule[];

///
struct Rule {
  ///
  Selector[] selectors;
  ///
  Declaration[] declarations;
}

/// A CSS rule, i.e. a property and its `gooey.css.values.Value`(s).
struct Declaration {
  /// Property name.
  string name;
  ///
  Value[] values;
  /// Whenter this rule is an an "!important" declaration.
  ///
  /// Declaring a <a href="https://drafts.csswg.org/css2/#shorthand-properties">shorthand property</a> (e.g., `background`) to be "!important" is equivalent to declaring all of its sub-properties to be "!important".
  /// See_Also: <a href="https://drafts.csswg.org/css2/#important-rules">!importatnt rules</a> - CSS 2 Specification
  bool important;
}
