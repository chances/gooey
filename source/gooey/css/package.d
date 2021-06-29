module gooey.css;

public import gooey.css.parser;
public import gooey.css.selectors;
public import gooey.css.values;

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
