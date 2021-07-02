module gooey.css.parser;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

struct GenericCSS(TParseTree)
{
    import std.functional : toDelegate;
    import pegged.dynamic.grammar;
    static import pegged.peg;
    struct CSS
    {
    enum name = "CSS";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    static this()
    {
        rules["ruleset"] = toDelegate(&ruleset);
        rules["selectors"] = toDelegate(&selectors);
        rules["selector"] = toDelegate(&selector);
        rules["combinator"] = toDelegate(&combinator);
        rules["simpleSelector"] = toDelegate(&simpleSelector);
        rules["elementName"] = toDelegate(&elementName);
        rules["class_"] = toDelegate(&class_);
        rules["attribute"] = toDelegate(&attribute);
        rules["pseudo"] = toDelegate(&pseudo);
        rules["declarations"] = toDelegate(&declarations);
        rules["declaration"] = toDelegate(&declaration);
        rules["property"] = toDelegate(&property);
        rules["expr"] = toDelegate(&expr);
        rules["term"] = toDelegate(&term);
        rules["unit"] = toDelegate(&unit);
        rules["function_"] = toDelegate(&function_);
        rules["unary_operator"] = toDelegate(&unary_operator);
        rules["operator"] = toDelegate(&operator);
        rules["hex"] = toDelegate(&hex);
        rules["unicode"] = toDelegate(&unicode);
        rules["unicodePoint"] = toDelegate(&unicodePoint);
        rules["escape"] = toDelegate(&escape);
        rules["stringChar"] = toDelegate(&stringChar);
        rules["string1"] = toDelegate(&string1);
        rules["string2"] = toDelegate(&string2);
        rules["string_"] = toDelegate(&string_);
        rules["unclosedString1"] = toDelegate(&unclosedString1);
        rules["unclosedString2"] = toDelegate(&unclosedString2);
        rules["unclosedString"] = toDelegate(&unclosedString);
        rules["url"] = toDelegate(&url);
        rules["uri"] = toDelegate(&uri);
        rules["unclosedUri1"] = toDelegate(&unclosedUri1);
        rules["unclosedUri2"] = toDelegate(&unclosedUri2);
        rules["unclosedUri3"] = toDelegate(&unclosedUri3);
        rules["unclosedUri"] = toDelegate(&unclosedUri);
        rules["nameHead"] = toDelegate(&nameHead);
        rules["nameTail"] = toDelegate(&nameTail);
        rules["identifier"] = toDelegate(&identifier);
        rules["number"] = toDelegate(&number);
        rules["newline"] = toDelegate(&newline);
        rules["_"] = toDelegate(&_);
        rules["w"] = toDelegate(&w);
        rules["hash"] = toDelegate(&hash);
        rules["hexcolor"] = toDelegate(&hexcolor);
        rules["includes"] = toDelegate(&includes);
        rules["dashMatch"] = toDelegate(&dashMatch);
        rules["import_"] = toDelegate(&import_);
        rules["media"] = toDelegate(&media);
        rules["important"] = toDelegate(&important);
        rules["em"] = toDelegate(&em);
        rules["ex"] = toDelegate(&ex);
        rules["rem"] = toDelegate(&rem);
        rules["percent"] = toDelegate(&percent);
        rules["length"] = toDelegate(&length);
        rules["angle"] = toDelegate(&angle);
        rules["time"] = toDelegate(&time);
        rules["frequency"] = toDelegate(&frequency);
        rules["Spacing"] = toDelegate(&Spacing);
    }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
        {
            if (ruleName != "Spacing")
                rules[ruleName] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
        import std.algorithm : startsWith;
        return s.startsWith("CSS.");
    }
    mixin decimateTree;

    alias spacing Spacing;

    static TParseTree ruleset(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(selectors, _, pegged.peg.literal!("{"), _, declarations, _, pegged.peg.literal!("}"), pegged.peg.zeroOrMore!(_)), "CSS.ruleset")(p);
        }
        else
        {
            if (auto m = tuple(`ruleset`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(selectors, _, pegged.peg.literal!("{"), _, declarations, _, pegged.peg.literal!("}"), pegged.peg.zeroOrMore!(_)), "CSS.ruleset"), "ruleset")(p);
                memo[tuple(`ruleset`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ruleset(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(selectors, _, pegged.peg.literal!("{"), _, declarations, _, pegged.peg.literal!("}"), pegged.peg.zeroOrMore!(_)), "CSS.ruleset")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(selectors, _, pegged.peg.literal!("{"), _, declarations, _, pegged.peg.literal!("}"), pegged.peg.zeroOrMore!(_)), "CSS.ruleset"), "ruleset")(TParseTree("", false,[], s));
        }
    }
    static string ruleset(GetName g)
    {
        return "CSS.ruleset";
    }

    static TParseTree selectors(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(selector, _, pegged.peg.literal!(","), _, selector), selector), "CSS.selectors")(p);
        }
        else
        {
            if (auto m = tuple(`selectors`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(selector, _, pegged.peg.literal!(","), _, selector), selector), "CSS.selectors"), "selectors")(p);
                memo[tuple(`selectors`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree selectors(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(selector, _, pegged.peg.literal!(","), _, selector), selector), "CSS.selectors")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(selector, _, pegged.peg.literal!(","), _, selector), selector), "CSS.selectors"), "selectors")(TParseTree("", false,[], s));
        }
    }
    static string selectors(GetName g)
    {
        return "CSS.selectors";
    }

    static TParseTree selector(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(simpleSelector, pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(combinator, selector), pegged.peg.and!(pegged.peg.oneOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.option!(combinator), selector)))))), "CSS.selector")(p);
        }
        else
        {
            if (auto m = tuple(`selector`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(simpleSelector, pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(combinator, selector), pegged.peg.and!(pegged.peg.oneOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.option!(combinator), selector)))))), "CSS.selector"), "selector")(p);
                memo[tuple(`selector`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree selector(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(simpleSelector, pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(combinator, selector), pegged.peg.and!(pegged.peg.oneOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.option!(combinator), selector)))))), "CSS.selector")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(simpleSelector, pegged.peg.option!(pegged.peg.or!(pegged.peg.and!(combinator, selector), pegged.peg.and!(pegged.peg.oneOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.option!(combinator), selector)))))), "CSS.selector"), "selector")(TParseTree("", false,[], s));
        }
    }
    static string selector(GetName g)
    {
        return "CSS.selector";
    }

    static TParseTree combinator(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("+"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(">"), pegged.peg.zeroOrMore!(_))), "CSS.combinator")(p);
        }
        else
        {
            if (auto m = tuple(`combinator`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("+"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(">"), pegged.peg.zeroOrMore!(_))), "CSS.combinator"), "combinator")(p);
                memo[tuple(`combinator`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree combinator(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("+"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(">"), pegged.peg.zeroOrMore!(_))), "CSS.combinator")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("+"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(">"), pegged.peg.zeroOrMore!(_))), "CSS.combinator"), "combinator")(TParseTree("", false,[], s));
        }
    }
    static string combinator(GetName g)
    {
        return "CSS.combinator";
    }

    static TParseTree simpleSelector(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(elementName, pegged.peg.zeroOrMore!(pegged.peg.or!(hash, class_, attribute, pseudo))), pegged.peg.oneOrMore!(pegged.peg.longest_match!(hash, class_, attribute, pseudo))), "CSS.simpleSelector")(p);
        }
        else
        {
            if (auto m = tuple(`simpleSelector`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(elementName, pegged.peg.zeroOrMore!(pegged.peg.or!(hash, class_, attribute, pseudo))), pegged.peg.oneOrMore!(pegged.peg.longest_match!(hash, class_, attribute, pseudo))), "CSS.simpleSelector"), "simpleSelector")(p);
                memo[tuple(`simpleSelector`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree simpleSelector(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(elementName, pegged.peg.zeroOrMore!(pegged.peg.or!(hash, class_, attribute, pseudo))), pegged.peg.oneOrMore!(pegged.peg.longest_match!(hash, class_, attribute, pseudo))), "CSS.simpleSelector")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(elementName, pegged.peg.zeroOrMore!(pegged.peg.or!(hash, class_, attribute, pseudo))), pegged.peg.oneOrMore!(pegged.peg.longest_match!(hash, class_, attribute, pseudo))), "CSS.simpleSelector"), "simpleSelector")(TParseTree("", false,[], s));
        }
    }
    static string simpleSelector(GetName g)
    {
        return "CSS.simpleSelector";
    }

    static TParseTree elementName(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(identifier, pegged.peg.literal!("*")), "CSS.elementName")(p);
        }
        else
        {
            if (auto m = tuple(`elementName`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(identifier, pegged.peg.literal!("*")), "CSS.elementName"), "elementName")(p);
                memo[tuple(`elementName`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree elementName(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(identifier, pegged.peg.literal!("*")), "CSS.elementName")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(identifier, pegged.peg.literal!("*")), "CSS.elementName"), "elementName")(TParseTree("", false,[], s));
        }
    }
    static string elementName(GetName g)
    {
        return "CSS.elementName";
    }

    static TParseTree class_(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("."), identifier), "CSS.class_")(p);
        }
        else
        {
            if (auto m = tuple(`class_`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("."), identifier), "CSS.class_"), "class_")(p);
                memo[tuple(`class_`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree class_(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("."), identifier), "CSS.class_")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("."), identifier), "CSS.class_"), "class_")(TParseTree("", false,[], s));
        }
    }
    static string class_(GetName g)
    {
        return "CSS.class_";
    }

    static TParseTree attribute(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("["), pegged.peg.zeroOrMore!(_), identifier, pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!("="), includes, dashMatch), pegged.peg.zeroOrMore!(_), pegged.peg.or!(identifier, string_), pegged.peg.zeroOrMore!(_))), pegged.peg.literal!("]")), "CSS.attribute")(p);
        }
        else
        {
            if (auto m = tuple(`attribute`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("["), pegged.peg.zeroOrMore!(_), identifier, pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!("="), includes, dashMatch), pegged.peg.zeroOrMore!(_), pegged.peg.or!(identifier, string_), pegged.peg.zeroOrMore!(_))), pegged.peg.literal!("]")), "CSS.attribute"), "attribute")(p);
                memo[tuple(`attribute`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree attribute(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("["), pegged.peg.zeroOrMore!(_), identifier, pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!("="), includes, dashMatch), pegged.peg.zeroOrMore!(_), pegged.peg.or!(identifier, string_), pegged.peg.zeroOrMore!(_))), pegged.peg.literal!("]")), "CSS.attribute")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("["), pegged.peg.zeroOrMore!(_), identifier, pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!("="), includes, dashMatch), pegged.peg.zeroOrMore!(_), pegged.peg.or!(identifier, string_), pegged.peg.zeroOrMore!(_))), pegged.peg.literal!("]")), "CSS.attribute"), "attribute")(TParseTree("", false,[], s));
        }
    }
    static string attribute(GetName g)
    {
        return "CSS.attribute";
    }

    static TParseTree pseudo(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!(":"), pegged.peg.or!(identifier, pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")))), "CSS.pseudo")(p);
        }
        else
        {
            if (auto m = tuple(`pseudo`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!(":"), pegged.peg.or!(identifier, pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")))), "CSS.pseudo"), "pseudo")(p);
                memo[tuple(`pseudo`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree pseudo(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!(":"), pegged.peg.or!(identifier, pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")))), "CSS.pseudo")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!(":"), pegged.peg.or!(identifier, pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")))), "CSS.pseudo"), "pseudo")(TParseTree("", false,[], s));
        }
    }
    static string pseudo(GetName g)
    {
        return "CSS.pseudo";
    }

    static TParseTree declarations(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(declaration), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.literal!(";"), pegged.peg.zeroOrMore!(_), pegged.peg.option!(declaration)))), "CSS.declarations")(p);
        }
        else
        {
            if (auto m = tuple(`declarations`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(declaration), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.literal!(";"), pegged.peg.zeroOrMore!(_), pegged.peg.option!(declaration)))), "CSS.declarations"), "declarations")(p);
                memo[tuple(`declarations`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree declarations(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(declaration), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.literal!(";"), pegged.peg.zeroOrMore!(_), pegged.peg.option!(declaration)))), "CSS.declarations")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.option!(declaration), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.literal!(";"), pegged.peg.zeroOrMore!(_), pegged.peg.option!(declaration)))), "CSS.declarations"), "declarations")(TParseTree("", false,[], s));
        }
    }
    static string declarations(GetName g)
    {
        return "CSS.declarations";
    }

    static TParseTree declaration(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(property, pegged.peg.literal!(":"), pegged.peg.zeroOrMore!(_), expr, pegged.peg.option!(pegged.peg.and!(important, pegged.peg.zeroOrMore!(_)))), "CSS.declaration")(p);
        }
        else
        {
            if (auto m = tuple(`declaration`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(property, pegged.peg.literal!(":"), pegged.peg.zeroOrMore!(_), expr, pegged.peg.option!(pegged.peg.and!(important, pegged.peg.zeroOrMore!(_)))), "CSS.declaration"), "declaration")(p);
                memo[tuple(`declaration`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree declaration(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(property, pegged.peg.literal!(":"), pegged.peg.zeroOrMore!(_), expr, pegged.peg.option!(pegged.peg.and!(important, pegged.peg.zeroOrMore!(_)))), "CSS.declaration")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(property, pegged.peg.literal!(":"), pegged.peg.zeroOrMore!(_), expr, pegged.peg.option!(pegged.peg.and!(important, pegged.peg.zeroOrMore!(_)))), "CSS.declaration"), "declaration")(TParseTree("", false,[], s));
        }
    }
    static string declaration(GetName g)
    {
        return "CSS.declaration";
    }

    static TParseTree property(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), "CSS.property")(p);
        }
        else
        {
            if (auto m = tuple(`property`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), "CSS.property"), "property")(p);
                memo[tuple(`property`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree property(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), "CSS.property")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), "CSS.property"), "property")(TParseTree("", false,[], s));
        }
    }
    static string property(GetName g)
    {
        return "CSS.property";
    }

    static TParseTree expr(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.option!(operator), term))), "CSS.expr")(p);
        }
        else
        {
            if (auto m = tuple(`expr`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.option!(operator), term))), "CSS.expr"), "expr")(p);
                memo[tuple(`expr`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree expr(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.option!(operator), term))), "CSS.expr")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(term, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.option!(operator), term))), "CSS.expr"), "expr")(TParseTree("", false,[], s));
        }
    }
    static string expr(GetName g)
    {
        return "CSS.expr";
    }

    static TParseTree term(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(unary_operator), unit, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(string_, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(uri, pegged.peg.zeroOrMore!(_)), hexcolor, function_), "CSS.term")(p);
        }
        else
        {
            if (auto m = tuple(`term`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(unary_operator), unit, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(string_, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(uri, pegged.peg.zeroOrMore!(_)), hexcolor, function_), "CSS.term"), "term")(p);
                memo[tuple(`term`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree term(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(unary_operator), unit, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(string_, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(uri, pegged.peg.zeroOrMore!(_)), hexcolor, function_), "CSS.term")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.option!(unary_operator), unit, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(string_, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_)), pegged.peg.and!(uri, pegged.peg.zeroOrMore!(_)), hexcolor, function_), "CSS.term"), "term")(TParseTree("", false,[], s));
        }
    }
    static string term(GetName g)
    {
        return "CSS.term";
    }

    static TParseTree unit(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(percent, length, em, ex, rem, angle, time, frequency, number), "CSS.unit")(p);
        }
        else
        {
            if (auto m = tuple(`unit`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(percent, length, em, ex, rem, angle, time, frequency, number), "CSS.unit"), "unit")(p);
                memo[tuple(`unit`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unit(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(percent, length, em, ex, rem, angle, time, frequency, number), "CSS.unit")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(percent, length, em, ex, rem, angle, time, frequency, number), "CSS.unit"), "unit")(TParseTree("", false,[], s));
        }
    }
    static string unit(GetName g)
    {
        return "CSS.unit";
    }

    static TParseTree function_(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")), "CSS.function_")(p);
        }
        else
        {
            if (auto m = tuple(`function_`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")), "CSS.function_"), "function_")(p);
                memo[tuple(`function_`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree function_(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")), "CSS.function_")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(identifier, pegged.peg.literal!("("), pegged.peg.zeroOrMore!(_), pegged.peg.option!(pegged.peg.and!(identifier, pegged.peg.zeroOrMore!(_))), pegged.peg.literal!(")")), "CSS.function_"), "function_")(TParseTree("", false,[], s));
        }
    }
    static string function_(GetName g)
    {
        return "CSS.function_";
    }

    static TParseTree unary_operator(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "CSS.unary_operator")(p);
        }
        else
        {
            if (auto m = tuple(`unary_operator`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "CSS.unary_operator"), "unary_operator")(p);
                memo[tuple(`unary_operator`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unary_operator(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "CSS.unary_operator")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("-", "+"), "CSS.unary_operator"), "unary_operator")(TParseTree("", false,[], s));
        }
    }
    static string unary_operator(GetName g)
    {
        return "CSS.unary_operator";
    }

    static TParseTree operator(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("/"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(","), pegged.peg.zeroOrMore!(_))), "CSS.operator")(p);
        }
        else
        {
            if (auto m = tuple(`operator`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("/"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(","), pegged.peg.zeroOrMore!(_))), "CSS.operator"), "operator")(p);
                memo[tuple(`operator`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree operator(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("/"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(","), pegged.peg.zeroOrMore!(_))), "CSS.operator")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("/"), pegged.peg.zeroOrMore!(_)), pegged.peg.and!(pegged.peg.literal!(","), pegged.peg.zeroOrMore!(_))), "CSS.operator"), "operator")(TParseTree("", false,[], s));
        }
    }
    static string operator(GetName g)
    {
        return "CSS.operator";
    }

    static TParseTree hex(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f')), "CSS.hex")(p);
        }
        else
        {
            if (auto m = tuple(`hex`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f')), "CSS.hex"), "hex")(p);
                memo[tuple(`hex`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree hex(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f')), "CSS.hex")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f')), "CSS.hex"), "hex")(TParseTree("", false,[], s));
        }
    }
    static string hex(GetName g)
    {
        return "CSS.hex";
    }

    static TParseTree unicode(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("\\"), unicodePoint, pegged.peg.option!(pegged.peg.or!(pegged.peg.literal!("\r\n"), pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))))), "CSS.unicode")(p);
        }
        else
        {
            if (auto m = tuple(`unicode`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("\\"), unicodePoint, pegged.peg.option!(pegged.peg.or!(pegged.peg.literal!("\r\n"), pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))))), "CSS.unicode"), "unicode")(p);
                memo[tuple(`unicode`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unicode(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("\\"), unicodePoint, pegged.peg.option!(pegged.peg.or!(pegged.peg.literal!("\r\n"), pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))))), "CSS.unicode")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("\\"), unicodePoint, pegged.peg.option!(pegged.peg.or!(pegged.peg.literal!("\r\n"), pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))))), "CSS.unicode"), "unicode")(TParseTree("", false,[], s));
        }
    }
    static string unicode(GetName g)
    {
        return "CSS.unicode";
    }

    static TParseTree unicodePoint(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(hex, hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex), pegged.peg.and!(hex, hex), hex), "CSS.unicodePoint")(p);
        }
        else
        {
            if (auto m = tuple(`unicodePoint`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(hex, hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex), pegged.peg.and!(hex, hex), hex), "CSS.unicodePoint"), "unicodePoint")(p);
                memo[tuple(`unicodePoint`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unicodePoint(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(hex, hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex), pegged.peg.and!(hex, hex), hex), "CSS.unicodePoint")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(hex, hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex, hex), pegged.peg.and!(hex, hex, hex), pegged.peg.and!(hex, hex), hex), "CSS.unicodePoint"), "unicodePoint")(TParseTree("", false,[], s));
        }
    }
    static string unicodePoint(GetName g)
    {
        return "CSS.unicodePoint";
    }

    static TParseTree escape(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unicode, pegged.peg.and!(backslash, pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\r"), pegged.peg.literal!("\n"), pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'))), pegged.peg.any)), "CSS.escape")(p);
        }
        else
        {
            if (auto m = tuple(`escape`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(unicode, pegged.peg.and!(backslash, pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\r"), pegged.peg.literal!("\n"), pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'))), pegged.peg.any)), "CSS.escape"), "escape")(p);
                memo[tuple(`escape`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree escape(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unicode, pegged.peg.and!(backslash, pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\r"), pegged.peg.literal!("\n"), pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'))), pegged.peg.any)), "CSS.escape")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(unicode, pegged.peg.and!(backslash, pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\r"), pegged.peg.literal!("\n"), pegged.peg.charRange!('0', '9'), pegged.peg.charRange!('a', 'f'))), pegged.peg.any)), "CSS.escape"), "escape")(TParseTree("", false,[], s));
        }
    }
    static string escape(GetName g)
    {
        return "CSS.escape";
    }

    static TParseTree stringChar(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(escape, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\n"), pegged.peg.literal!("\r"), pegged.peg.literal!(`"`))), pegged.peg.any)), "CSS.stringChar")(p);
        }
        else
        {
            if (auto m = tuple(`stringChar`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(escape, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\n"), pegged.peg.literal!("\r"), pegged.peg.literal!(`"`))), pegged.peg.any)), "CSS.stringChar"), "stringChar")(p);
                memo[tuple(`stringChar`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree stringChar(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(escape, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\n"), pegged.peg.literal!("\r"), pegged.peg.literal!(`"`))), pegged.peg.any)), "CSS.stringChar")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(escape, pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(pegged.peg.literal!("\n"), pegged.peg.literal!("\r"), pegged.peg.literal!(`"`))), pegged.peg.any)), "CSS.stringChar"), "stringChar")(TParseTree("", false,[], s));
        }
    }
    static string stringChar(GetName g)
    {
        return "CSS.stringChar";
    }

    static TParseTree string1(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.discard!(doublequote)), "CSS.string1")(p);
        }
        else
        {
            if (auto m = tuple(`string1`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.discard!(doublequote)), "CSS.string1"), "string1")(p);
                memo[tuple(`string1`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree string1(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.discard!(doublequote)), "CSS.string1")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(doublequote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.discard!(doublequote)), "CSS.string1"), "string1")(TParseTree("", false,[], s));
        }
    }
    static string string1(GetName g)
    {
        return "CSS.string1";
    }

    static TParseTree string2(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(quote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.discard!(quote)), "CSS.string2")(p);
        }
        else
        {
            if (auto m = tuple(`string2`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(quote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.discard!(quote)), "CSS.string2"), "string2")(p);
                memo[tuple(`string2`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree string2(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(quote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.discard!(quote)), "CSS.string2")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(quote), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.discard!(quote)), "CSS.string2"), "string2")(TParseTree("", false,[], s));
        }
    }
    static string string2(GetName g)
    {
        return "CSS.string2";
    }

    static TParseTree string_(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(string1, string2)), "CSS.string_")(p);
        }
        else
        {
            if (auto m = tuple(`string_`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(string1, string2)), "CSS.string_"), "string_")(p);
                memo[tuple(`string_`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree string_(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(string1, string2)), "CSS.string_")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(string1, string2)), "CSS.string_"), "string_")(TParseTree("", false,[], s));
        }
    }
    static string string_(GetName g)
    {
        return "CSS.string_";
    }

    static TParseTree unclosedString1(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString1")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedString1`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString1"), "unclosedString1")(p);
                memo[tuple(`unclosedString1`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedString1(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString1")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(doublequote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(doublequote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString1"), "unclosedString1")(TParseTree("", false,[], s));
        }
    }
    static string unclosedString1(GetName g)
    {
        return "CSS.unclosedString1";
    }

    static TParseTree unclosedString2(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(quote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString2")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedString2`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(quote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString2"), "unclosedString2")(p);
                memo[tuple(`unclosedString2`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedString2(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(quote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString2")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(quote, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(quote), stringChar)), pegged.peg.option!(backslash)), "CSS.unclosedString2"), "unclosedString2")(TParseTree("", false,[], s));
        }
    }
    static string unclosedString2(GetName g)
    {
        return "CSS.unclosedString2";
    }

    static TParseTree unclosedString(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unclosedString1, unclosedString2), "CSS.unclosedString")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedString`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(unclosedString1, unclosedString2), "CSS.unclosedString"), "unclosedString")(p);
                memo[tuple(`unclosedString`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedString(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unclosedString1, unclosedString2), "CSS.unclosedString")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(unclosedString1, unclosedString2), "CSS.unclosedString"), "unclosedString")(TParseTree("", false,[], s));
        }
    }
    static string unclosedString(GetName g)
    {
        return "CSS.unclosedString";
    }

    static TParseTree url(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '~')), escape)), "CSS.url")(p);
        }
        else
        {
            if (auto m = tuple(`url`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '~')), escape)), "CSS.url"), "url")(p);
                memo[tuple(`url`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree url(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '~')), escape)), "CSS.url")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '~')), escape)), "CSS.url"), "url")(TParseTree("", false,[], s));
        }
    }
    static string url(GetName g)
    {
        return "CSS.url";
    }

    static TParseTree uri(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("url("), w, string_, w, pegged.peg.literal!(")")), pegged.peg.and!(pegged.peg.literal!("url("), w, url, w, pegged.peg.literal!(")"))), "CSS.uri")(p);
        }
        else
        {
            if (auto m = tuple(`uri`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("url("), w, string_, w, pegged.peg.literal!(")")), pegged.peg.and!(pegged.peg.literal!("url("), w, url, w, pegged.peg.literal!(")"))), "CSS.uri"), "uri")(p);
                memo[tuple(`uri`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree uri(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("url("), w, string_, w, pegged.peg.literal!(")")), pegged.peg.and!(pegged.peg.literal!("url("), w, url, w, pegged.peg.literal!(")"))), "CSS.uri")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("url("), w, string_, w, pegged.peg.literal!(")")), pegged.peg.and!(pegged.peg.literal!("url("), w, url, w, pegged.peg.literal!(")"))), "CSS.uri"), "uri")(TParseTree("", false,[], s));
        }
    }
    static string uri(GetName g)
    {
        return "CSS.uri";
    }

    static TParseTree unclosedUri1(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '['), pegged.peg.charRange!(']', '~')), escape)), _), "CSS.unclosedUri1")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedUri1`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '['), pegged.peg.charRange!(']', '~')), escape)), _), "CSS.unclosedUri1"), "unclosedUri1")(p);
                memo[tuple(`unclosedUri1`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedUri1(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '['), pegged.peg.charRange!(']', '~')), escape)), _), "CSS.unclosedUri1")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.or!(pegged.peg.literal!("!"), pegged.peg.literal!("#"), pegged.peg.literal!("$"), pegged.peg.literal!("%"), pegged.peg.literal!("&"), pegged.peg.charRange!('*', '['), pegged.peg.charRange!(']', '~')), escape)), _), "CSS.unclosedUri1"), "unclosedUri1")(TParseTree("", false,[], s));
        }
    }
    static string unclosedUri1(GetName g)
    {
        return "CSS.unclosedUri1";
    }

    static TParseTree unclosedUri2(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, string_, _), "CSS.unclosedUri2")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedUri2`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, string_, _), "CSS.unclosedUri2"), "unclosedUri2")(p);
                memo[tuple(`unclosedUri2`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedUri2(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, string_, _), "CSS.unclosedUri2")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, string_, _), "CSS.unclosedUri2"), "unclosedUri2")(TParseTree("", false,[], s));
        }
    }
    static string unclosedUri2(GetName g)
    {
        return "CSS.unclosedUri2";
    }

    static TParseTree unclosedUri3(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, unclosedString), "CSS.unclosedUri3")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedUri3`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, unclosedString), "CSS.unclosedUri3"), "unclosedUri3")(p);
                memo[tuple(`unclosedUri3`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedUri3(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, unclosedString), "CSS.unclosedUri3")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("url("), _, unclosedString), "CSS.unclosedUri3"), "unclosedUri3")(TParseTree("", false,[], s));
        }
    }
    static string unclosedUri3(GetName g)
    {
        return "CSS.unclosedUri3";
    }

    static TParseTree unclosedUri(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unclosedUri1, unclosedUri2, unclosedUri3), "CSS.unclosedUri")(p);
        }
        else
        {
            if (auto m = tuple(`unclosedUri`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(unclosedUri1, unclosedUri2, unclosedUri3), "CSS.unclosedUri"), "unclosedUri")(p);
                memo[tuple(`unclosedUri`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree unclosedUri(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(unclosedUri1, unclosedUri2, unclosedUri3), "CSS.unclosedUri")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(unclosedUri1, unclosedUri2, unclosedUri3), "CSS.unclosedUri"), "unclosedUri")(TParseTree("", false,[], s));
        }
    }
    static string unclosedUri(GetName g)
    {
        return "CSS.unclosedUri";
    }

    static TParseTree nameHead(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.literal!("_")), "CSS.nameHead")(p);
        }
        else
        {
            if (auto m = tuple(`nameHead`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.literal!("_")), "CSS.nameHead"), "nameHead")(p);
                memo[tuple(`nameHead`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree nameHead(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.literal!("_")), "CSS.nameHead")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.literal!("_")), "CSS.nameHead"), "nameHead")(TParseTree("", false,[], s));
        }
    }
    static string nameHead(GetName g)
    {
        return "CSS.nameHead";
    }

    static TParseTree nameTail(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), pegged.peg.literal!("-"), escape), "CSS.nameTail")(p);
        }
        else
        {
            if (auto m = tuple(`nameTail`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), pegged.peg.literal!("-"), escape), "CSS.nameTail"), "nameTail")(p);
                memo[tuple(`nameTail`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree nameTail(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), pegged.peg.literal!("-"), escape), "CSS.nameTail")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.or!(pegged.peg.charRange!('A', 'Z'), pegged.peg.charRange!('a', 'z'), pegged.peg.charRange!('0', '9'), pegged.peg.literal!("_")), pegged.peg.literal!("-"), escape), "CSS.nameTail"), "nameTail")(TParseTree("", false,[], s));
        }
    }
    static string nameTail(GetName g)
    {
        return "CSS.nameTail";
    }

    static TParseTree identifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), nameHead, pegged.peg.zeroOrMore!(nameTail))), "CSS.identifier")(p);
        }
        else
        {
            if (auto m = tuple(`identifier`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), nameHead, pegged.peg.zeroOrMore!(nameTail))), "CSS.identifier"), "identifier")(p);
                memo[tuple(`identifier`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree identifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), nameHead, pegged.peg.zeroOrMore!(nameTail))), "CSS.identifier")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), nameHead, pegged.peg.zeroOrMore!(nameTail))), "CSS.identifier"), "identifier")(TParseTree("", false,[], s));
        }
    }
    static string identifier(GetName g)
    {
        return "CSS.identifier";
    }

    static TParseTree number(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "CSS.number")(p);
        }
        else
        {
            if (auto m = tuple(`number`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "CSS.number"), "number")(p);
                memo[tuple(`number`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree number(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "CSS.number")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.or!(pegged.peg.and!(pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9'))), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "CSS.number"), "number")(TParseTree("", false,[], s));
        }
    }
    static string number(GetName g)
    {
        return "CSS.number";
    }

    static TParseTree newline(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("\n", "\r\n", "\r"), "CSS.newline")(p);
        }
        else
        {
            if (auto m = tuple(`newline`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.keywords!("\n", "\r\n", "\r"), "CSS.newline"), "newline")(p);
                memo[tuple(`newline`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree newline(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.keywords!("\n", "\r\n", "\r"), "CSS.newline")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.keywords!("\n", "\r\n", "\r"), "CSS.newline"), "newline")(TParseTree("", false,[], s));
        }
    }
    static string newline(GetName g)
    {
        return "CSS.newline";
    }

    static TParseTree _(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))), "CSS._")(p);
        }
        else
        {
            if (auto m = tuple(`_`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))), "CSS._"), "_")(p);
                memo[tuple(`_`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree _(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))), "CSS._")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.oneOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t"), pegged.peg.literal!("\r"), pegged.peg.literal!("\n"))), "CSS._"), "_")(TParseTree("", false,[], s));
        }
    }
    static string _(GetName g)
    {
        return "CSS._";
    }

    static TParseTree w(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.option!(_), "CSS.w")(p);
        }
        else
        {
            if (auto m = tuple(`w`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.option!(_), "CSS.w"), "w")(p);
                memo[tuple(`w`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree w(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.option!(_), "CSS.w")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.option!(_), "CSS.w"), "w")(TParseTree("", false,[], s));
        }
    }
    static string w(GetName g)
    {
        return "CSS.w";
    }

    static TParseTree hash(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.fuse!(pegged.peg.oneOrMore!(nameTail))), "CSS.hash")(p);
        }
        else
        {
            if (auto m = tuple(`hash`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.fuse!(pegged.peg.oneOrMore!(nameTail))), "CSS.hash"), "hash")(p);
                memo[tuple(`hash`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree hash(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.fuse!(pegged.peg.oneOrMore!(nameTail))), "CSS.hash")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.literal!("#"), pegged.peg.fuse!(pegged.peg.oneOrMore!(nameTail))), "CSS.hash"), "hash")(TParseTree("", false,[], s));
        }
    }
    static string hash(GetName g)
    {
        return "CSS.hash";
    }

    static TParseTree hexcolor(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex, hex, hex, hex), pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex)), "CSS.hexcolor")(p);
        }
        else
        {
            if (auto m = tuple(`hexcolor`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex, hex, hex, hex), pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex)), "CSS.hexcolor"), "hexcolor")(p);
                memo[tuple(`hexcolor`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree hexcolor(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex, hex, hex, hex), pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex)), "CSS.hexcolor")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex, hex, hex, hex), pegged.peg.and!(pegged.peg.literal!("#"), hex, hex, hex)), "CSS.hexcolor"), "hexcolor")(TParseTree("", false,[], s));
        }
    }
    static string hexcolor(GetName g)
    {
        return "CSS.hexcolor";
    }

    static TParseTree includes(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("~="), "CSS.includes")(p);
        }
        else
        {
            if (auto m = tuple(`includes`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("~="), "CSS.includes"), "includes")(p);
                memo[tuple(`includes`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree includes(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("~="), "CSS.includes")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("~="), "CSS.includes"), "includes")(TParseTree("", false,[], s));
        }
    }
    static string includes(GetName g)
    {
        return "CSS.includes";
    }

    static TParseTree dashMatch(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("|="), "CSS.dashMatch")(p);
        }
        else
        {
            if (auto m = tuple(`dashMatch`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("|="), "CSS.dashMatch"), "dashMatch")(p);
                memo[tuple(`dashMatch`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree dashMatch(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("|="), "CSS.dashMatch")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("|="), "CSS.dashMatch"), "dashMatch")(TParseTree("", false,[], s));
        }
    }
    static string dashMatch(GetName g)
    {
        return "CSS.dashMatch";
    }

    static TParseTree import_(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("@import"), "CSS.import_")(p);
        }
        else
        {
            if (auto m = tuple(`import_`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("@import"), "CSS.import_"), "import_")(p);
                memo[tuple(`import_`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree import_(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("@import"), "CSS.import_")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("@import"), "CSS.import_"), "import_")(TParseTree("", false,[], s));
        }
    }
    static string import_(GetName g)
    {
        return "CSS.import_";
    }

    static TParseTree media(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("@media"), "CSS.media")(p);
        }
        else
        {
            if (auto m = tuple(`media`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.literal!("@media"), "CSS.media"), "media")(p);
                memo[tuple(`media`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree media(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.literal!("@media"), "CSS.media")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.literal!("@media"), "CSS.media"), "media")(TParseTree("", false,[], s));
        }
    }
    static string media(GetName g)
    {
        return "CSS.media";
    }

    static TParseTree important(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("!important"), "CSS.important")(p);
        }
        else
        {
            if (auto m = tuple(`important`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("!important"), "CSS.important"), "important")(p);
                memo[tuple(`important`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree important(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("!important"), "CSS.important")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.caseInsensitiveLiteral!("!important"), "CSS.important"), "important")(TParseTree("", false,[], s));
        }
    }
    static string important(GetName g)
    {
        return "CSS.important";
    }

    static TParseTree em(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("em"))), "CSS.em")(p);
        }
        else
        {
            if (auto m = tuple(`em`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("em"))), "CSS.em"), "em")(p);
                memo[tuple(`em`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree em(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("em"))), "CSS.em")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("em"))), "CSS.em"), "em")(TParseTree("", false,[], s));
        }
    }
    static string em(GetName g)
    {
        return "CSS.em";
    }

    static TParseTree ex(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("ex"))), "CSS.ex")(p);
        }
        else
        {
            if (auto m = tuple(`ex`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("ex"))), "CSS.ex"), "ex")(p);
                memo[tuple(`ex`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree ex(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("ex"))), "CSS.ex")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("ex"))), "CSS.ex"), "ex")(TParseTree("", false,[], s));
        }
    }
    static string ex(GetName g)
    {
        return "CSS.ex";
    }

    static TParseTree rem(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("rem"))), "CSS.rem")(p);
        }
        else
        {
            if (auto m = tuple(`rem`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("rem"))), "CSS.rem"), "rem")(p);
                memo[tuple(`rem`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree rem(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("rem"))), "CSS.rem")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.caseInsensitiveLiteral!("rem"))), "CSS.rem"), "rem")(TParseTree("", false,[], s));
        }
    }
    static string rem(GetName g)
    {
        return "CSS.rem";
    }

    static TParseTree percent(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.literal!("%"))), "CSS.percent")(p);
        }
        else
        {
            if (auto m = tuple(`percent`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.literal!("%"))), "CSS.percent"), "percent")(p);
                memo[tuple(`percent`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree percent(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.literal!("%"))), "CSS.percent")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.literal!("%"))), "CSS.percent"), "percent")(TParseTree("", false,[], s));
        }
    }
    static string percent(GetName g)
    {
        return "CSS.percent";
    }

    static TParseTree length(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("px"), pegged.peg.caseInsensitiveLiteral!("cm"), pegged.peg.caseInsensitiveLiteral!("mm"), pegged.peg.caseInsensitiveLiteral!("in_"), pegged.peg.caseInsensitiveLiteral!("pt"), pegged.peg.caseInsensitiveLiteral!("pc")))), "CSS.length")(p);
        }
        else
        {
            if (auto m = tuple(`length`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("px"), pegged.peg.caseInsensitiveLiteral!("cm"), pegged.peg.caseInsensitiveLiteral!("mm"), pegged.peg.caseInsensitiveLiteral!("in_"), pegged.peg.caseInsensitiveLiteral!("pt"), pegged.peg.caseInsensitiveLiteral!("pc")))), "CSS.length"), "length")(p);
                memo[tuple(`length`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree length(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("px"), pegged.peg.caseInsensitiveLiteral!("cm"), pegged.peg.caseInsensitiveLiteral!("mm"), pegged.peg.caseInsensitiveLiteral!("in_"), pegged.peg.caseInsensitiveLiteral!("pt"), pegged.peg.caseInsensitiveLiteral!("pc")))), "CSS.length")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("px"), pegged.peg.caseInsensitiveLiteral!("cm"), pegged.peg.caseInsensitiveLiteral!("mm"), pegged.peg.caseInsensitiveLiteral!("in_"), pegged.peg.caseInsensitiveLiteral!("pt"), pegged.peg.caseInsensitiveLiteral!("pc")))), "CSS.length"), "length")(TParseTree("", false,[], s));
        }
    }
    static string length(GetName g)
    {
        return "CSS.length";
    }

    static TParseTree angle(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("deg"), pegged.peg.caseInsensitiveLiteral!("rad"), pegged.peg.caseInsensitiveLiteral!("grad")))), "CSS.angle")(p);
        }
        else
        {
            if (auto m = tuple(`angle`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("deg"), pegged.peg.caseInsensitiveLiteral!("rad"), pegged.peg.caseInsensitiveLiteral!("grad")))), "CSS.angle"), "angle")(p);
                memo[tuple(`angle`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree angle(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("deg"), pegged.peg.caseInsensitiveLiteral!("rad"), pegged.peg.caseInsensitiveLiteral!("grad")))), "CSS.angle")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("deg"), pegged.peg.caseInsensitiveLiteral!("rad"), pegged.peg.caseInsensitiveLiteral!("grad")))), "CSS.angle"), "angle")(TParseTree("", false,[], s));
        }
    }
    static string angle(GetName g)
    {
        return "CSS.angle";
    }

    static TParseTree time(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("ms"), pegged.peg.caseInsensitiveLiteral!("s")))), "CSS.time")(p);
        }
        else
        {
            if (auto m = tuple(`time`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("ms"), pegged.peg.caseInsensitiveLiteral!("s")))), "CSS.time"), "time")(p);
                memo[tuple(`time`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree time(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("ms"), pegged.peg.caseInsensitiveLiteral!("s")))), "CSS.time")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("ms"), pegged.peg.caseInsensitiveLiteral!("s")))), "CSS.time"), "time")(TParseTree("", false,[], s));
        }
    }
    static string time(GetName g)
    {
        return "CSS.time";
    }

    static TParseTree frequency(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hz"), pegged.peg.caseInsensitiveLiteral!("khz")))), "CSS.frequency")(p);
        }
        else
        {
            if (auto m = tuple(`frequency`, p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hz"), pegged.peg.caseInsensitiveLiteral!("khz")))), "CSS.frequency"), "frequency")(p);
                memo[tuple(`frequency`, p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree frequency(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hz"), pegged.peg.caseInsensitiveLiteral!("khz")))), "CSS.frequency")(TParseTree("", false,[], s));
        }
        else
        {
            forgetMemo();
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(number, pegged.peg.or!(pegged.peg.caseInsensitiveLiteral!("hz"), pegged.peg.caseInsensitiveLiteral!("khz")))), "CSS.frequency"), "frequency")(TParseTree("", false,[], s));
        }
    }
    static string frequency(GetName g)
    {
        return "CSS.frequency";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(ruleset(p));
        result.children = [result];
        result.name = "CSS";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return CSS(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            forgetMemo();
            return CSS(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "CSS";
    }


    static void forgetMemo()
    {
        memo = null;
    }
    }
}

alias GenericCSS!(ParseTree).CSS CSS;

