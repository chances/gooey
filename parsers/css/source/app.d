import std.stdio;

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
    simpleSelector  <- elementName ( hash / class_ / attribute / pseudo )*
    elementName     <-  identifier / '*'
    class_           <- '.' identifier
    attribute       <- '[' _* identifier _* ( ( '=' / includes / dashMatch ) _* ( identifier / string_ ) _* )? ']'
    pseudo          <- ':' ( identifier / identifier '(' _* (identifier _*)? ')' )

    declarations  <- declaration? ( ';' _* declaration? )*
    declaration   <- property ':' _* expr (important _*)?
    property <- identifier _*

    expr <- term ( operator? term )*
    term <- unary_operator? unit _* / string_ _* / identifier _* / uri _* / hexcolor / function_
    unit <- number / percent / length / ems / ex / angle / time / frequency
    function_ <- identifier '(' _* (identifier _*)? ')'
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
    string1   <- :doublequote stringChar* :doublequote
    string2   <- :quote stringChar* :quote
    string_   <- string1  / string2
    unclosedString1   <- doublequote stringChar* backslash?
    unclosedString2   <- quote stringChar* backslash?
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
    nameChar    <- [_a-z0-9-] / escape
    nameHead    <- [A-Za-z_]
    nameTail    <- [A-Za-z0-9_] / '-'
    identifier  <- '-'? nameHead nameTail*
    number <-		[0-9]+ / [0-9]* "." [0-9]+
    newline <- '\n' / '\r\n' / '\r'
    _ <- [ \t\r\n]+
    w <- _?

    hash <- '#' nameChar+
    hexcolor <- '#' hex hex hex hex hex hex / '#' hex hex hex
    includes <- "~="
    dashMatch <- "|="

    import_ <- '@import'
    media <- '@media'

    important <- '!important'i

    #==================================#
    # Units
    #==================================#
    percent <- '%'
    ems <- em / rem
    length <- px / cm / mm / in_ / pt / pc
    angle <- deg / rad / grad
    time <- ms / sec
    frequency <- hz / khz

    em <- 'em'i    #	EMs
    rem <- 'rem'i  # Relative EMs
    ex <- 'ex'i    #	EXs
    #	Lengths
    px  <- 'px'i    #	Pixels
    cm  <- 'cm'i    #	Centimeters
    mm  <- 'mm'i    #	Millimeters
    in_ <- 'in'i    #	Inches
    pt  <- 'pt'i    #	Points
    pc  <- 'pc'i    #	?
    # Angles
    deg <- 'deg'i       #	Degrees
    rad <- 'rad'i       #	Radians
    grad <- 'grad'i     # ?
    # Time (Duration)
    ms <- 'ms'i         #	Milliseconds
    sec <- 's'i         #	Seconds
    # Frequencies
    hz <- 'hz'i             #	Hertz
    khz <- 'khz'i / 'kHz'i  #	Frequency
  `);

  writeln("Written parser at " ~ destinationPath);
  writeln("Done.");
}
