import std.stdio;

/// Adapted from the CSS 2.1 Grammar (https://www.w3.org/TR/CSS21/grammar.html)
///
/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
import pegged.grammar;

void main()
{
	writeln("Geneerating CSS parser...");

  // For CSS units and '!important':
  // https://github.com/PhilippeSigaud/Pegged/wiki/Extended-PEG-Syntax#case-insensitive-literals

  const destinationPath = "./source/gooey/css/parser";
  asModule("gooey.css.parser", destinationPath, `
  CSS:
    ruleset <- selectors _ '{' _ declarations _ '}' _*

    selectors       <- selector _ ',' _ selector / selector
    selector        <- simpleSelector ( combinator selector / _+ ( combinator? selector )? )?
    combinator      <- '+' _* / '>' _*
    simpleSelector  <- elementName ( hash / class_ / attribute / pseudo )* / ( hash | class_ | attribute | pseudo )+
    elementName     <-  identifier / '*'
    class_           <- '.' identifier
    attribute       <- '[' _* identifier _* ( ( '=' / includes / dashMatch ) _* ( identifier / string_ ) _* )? ']'
    pseudo          <- ':' ( identifier / identifier '(' _* (identifier _*)? ')' )

    declarations  <- declaration? ( ';' _* declaration? )*
    declaration   <- property ':' _* expr (important _*)?
    property <- identifier _*

    expr <- term ( operator? _* term )*
    term <- unary_operator? unit _* / string_ _* / uri _* / function_ / identifier _* / hexcolor
    unit <- percent / length / em / ex / rem / angle / time / frequency / number
    function_ <- identifier '(' _* (expr _*)? ')'
    unary_operator <- '-' / '+'
    operator <- '/' _* / ',' _*

    #====================================================#
    # Tokens
    #====================================================#

    hex           <- [0-9a-f]
    unicode       <-		'\\' unicodePoint ( '\r\n' / [ \t\r\n] )?
    unicodePoint  <- hex hex hex hex hex hex / hex hex hex hex hex / hex hex hex hex / hex hex hex / hex hex / hex
    escape    <- unicode / (backslash ![\r\n0-9a-f] .)
    stringChar <- escape / (![\n\r\"] .)
    string1   <- :doublequote (!doublequote stringChar)* :doublequote
    string2   <- :quote (!quote stringChar)* :quote
    string_   <- ~(string1  / string2)
    unclosedString1   <- doublequote (!doublequote stringChar)* backslash?
    unclosedString2   <- quote (!quote stringChar)* backslash?
    unclosedString    <- unclosedString1 / unclosedString2
    url           <- ([!#$%&*-~] / escape)*
    uri           <- "url(" w string_ w ")" / "url(" w url w ")"
    unclosedUri1  <- 'url(' _ ([!#$%&*-\[\]-~] / escape)* _
    unclosedUri2  <- 'url(' _ string_ _
    unclosedUri3  <- 'url(' _ unclosedString
    unclosedUri   <- unclosedUri1 / unclosedUri2 / unclosedUri3
    # TODO: Use negative lookahead for comments
    # comment           <- '/*' [^*]* '*'+ ( [^/*] [^*]* '\*'+ )* '/'
    # unclosedComment1  <- '/*' [^*]* '*'+ ( [^/*] [^*]* '\*'+ )*
    # unclosedComment2  <- '/*' [^*]* ( \*+[^/*][^*]* )*
    # unclosedComment   <- unclosedComment1 / unclosedComment2
    nameHead    <- [A-Za-z_]
    nameTail    <- [A-Za-z0-9_] / '-' / escape
    identifier  <- ~('-'? nameHead nameTail*)
    number      <- ~([0-9]* "." [0-9]+ / "." [0-9]+ / [0-9]+)
    newline <- '\n' / '\r\n' / '\r'
    _ <- [ \t\r\n]+
    w <- _?

    hash <- '#' ~(nameTail+)
    hexcolor <- ~('#' hex hex hex hex hex hex / '#' hex hex hex)
    includes <- "~="
    dashMatch <- "|="

    import_ <- '@import'
    media <- '@media'

    important <- '!important'i

    #==================================#
    # Units
    #==================================#
    em  <- ~(number 'em'i)    #	EMs
    ex  <- ~(number 'ex'i)    # x-height
    rem <- ~(number 'rem'i)   # Relative EMs
    percent <- ~(number '%')
    length <- ~(number ('px'i / 'cm'i / 'mm'i / 'in_'i / 'pt'i / 'pc'i / 'vw'i / 'vh'i))
    angle <- ~(number ('deg'i / 'rad'i / 'grad'i))
    time <- ~(number ('ms'i / 's'i))
    frequency <- ~(number ('hz'i / 'khz'i))
  `);

  writeln("Written parser at " ~ destinationPath);
  writeln("Done.");
}
