module gooey.css;

public {
  import gooey.ast : SyntaxError;
  import gooey.css.parser;
  import gooey.css.selectors;
  import gooey.css.values;
}

alias RuleSet = Rule[];

struct Stylesheet {
  Rule[] rules;
}

struct Rule {
  Selector[] selectors;
  Declaration[] declarations;
}

struct Declaration {
  string name;
  Value[] values;
  bool important;
}

Stylesheet parse(string input) {
  assert(0, "Unimplemented!");
}
