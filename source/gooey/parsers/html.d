/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.parsers.html;

import std.algorithm : canFind, joiner;
import std.array : back, empty;
import std.conv : text, to;
import std.string : replace;
import gooey.dom : Attr, Document, Element;
import gooey.dom.nodes;
import pegged.grammar;

// https://html.spec.whatwg.org/multipage/parsing.html#parsing
// https://html.spec.whatwg.org/multipage/parsing.html#tokenization
private enum HtmlGrammar = `
HTML:
  Document        <   (Comment / Node / Text)*
  # TODO: Foreign         <-  PlainText / Script / SVG / Math
  Node            <-  TagClose / TagOpen
  TagOpen         <-  :tagLhs tag{tagOpen, appendNode} Attributes (:tagRhsSelfClose{tagClose} / :tagRhs)
  TagClose        <-  :nodeClose :tag :tagRhs
  Comment         <-  CommentOpen CommentValue{appendComment} CommentClose
  CommentOpen     <-  :"<!--"
  CommentClose    <-  :"-->"
  CommentValue    <-  (!:"-->" !:"--" .)*
  Attributes      <-  (Attribute)*
  Attribute       <-  attribute{appendAttribute} :equals (
                        :quote attributeValueQuotes{appendAttributeValue} :quote
                        / :apostrophe attributeValueApostrophe{appendAttributeValue} :apostrophe
                        / attributeValueUnquoted{appendAttributeValue}
                      )
                      / attribute{appendAttribute}
  Text            <~  (!tagLhs !nodeClose .)+{appendText}

  PlainText       <-  :tagLhs "plaintext"{tagOpen, appendNode} :tagRhs .*{fuseMatches, appendText}
  Script          <-  :tagLhs "script"{tagOpen} Attributes :tagRhs ((!:"</script>") .)*{fuseMatches, appendScript}
  SVG             <-  :tagLhs "svg"{tagOpen, appendNode} :tagRhs ((!:"</svg>") .)*{fuseMatches, appendText}
  Math            <-  :tagLhs "math"{tagOpen, appendNode} :tagRhs ((!:"</math>") .)*{fuseMatches, appendText}

  nodeClose                 <-  :tagLhs :solidus # </
  tag                       <-  identifierChar+{fuseMatches}
  identifierChar            <-  !:"/>" !:tagRhs [A-Za-z] / nullChar
  attribute                 <-  (!:solidus !:equals !:tagRhs .)+{fuseMatches}
  attributeValueUnquoted    <-  ampersand / (nullChar / !:tagRhsSelfClose !:tagRhs .)+
  attributeValueQuotes      <-  ampersand / (nullChar / !:quote !:tagRhsSelfClose !:tagRhs .)+
  attributeValueApostrophe  <-  ampersand / (nullChar / !:apostrophe !:tagRhsSelfClose !:tagRhs .)+

  tagLhs          <-  '\u003C' # U+003C LESS-THAN SIGN (<)
  tagRhs          <-  '\u003E' # U+003E GREATER-THAN SIGN (>)
  tagRhsSelfClose <-  :solidus :tagRhs
  solidus         <-  '\u002F' # U+002F SOLIDUS (/)
  equals          <-  '\u003D' # U+003D EQUALS SIGN (=)
  quote           <-  '\u0022' # U+0022 QUOTATION MARK (")
  apostrophe      <-  '\u0027' # U+0027 APOSTROPHE (')
  ampersand       <-  '\u0026' # U+0026 AMPERSAND (&)
  # TODO: https://html.spec.whatwg.org/multipage/parsing.html#character-reference-state
  nullChar        <-  '\0000'{replaceWithUnicodeReplacementCharacter}
`;

private:

Document doc;
Node parent;
Attr attribute;
enum initialMode = InsertionMode.beforeHtml;
auto mode = initialMode;
/// Full history of parse modes from start to finish.
debug InsertionMode[] modes = [initialMode];
auto scripting = false;
string[] tagStack = [];
string selfClosingTag;
debug string[] diagnostics;
/// Set of HTML tags that may be abiguiously self-closing.
const selfClosingTags = [
  "br",
  "dd",
  "dt",
  "li",
  "optgroup",
  "option",
  "p",
  "rb",
  "rp",
  "rt",
  "rtc",
  "tbody",
  "td",
  "tfoot",
  "th",
  "thead",
  "tr",
  "body",
  "html"
];

Element parentElement() @safe {
  import std.algorithm : equal;

  return typeid(Document).isBaseOf(parent.classinfo)
    ? parent.to!Document.documentElement
    : parent.to!Element;
}

mixin(grammar(HtmlGrammar));

/// See_Also: https://html.spec.whatwg.org/multipage/parsing.html#insertion-mode
enum InsertionMode {
  none,
  beforeHtml,
  beforeHead,
  inHead,
  afterHead,
  inBody,
  afterBody,
  afterAfterBody,
}

debug enum debugMode = true;
else enum debugMode = false;

string currentTag(O)(O o) @trusted {
  import std.string : replace, toLower;

  const tag = tagStack.empty ? o.fuseMatches.matches.joiner.text.toLower : tagStack.back;
  return selfClosingTag !is null ? selfClosingTag : tag.replace("image", "img").to!string;
}

O tagOpen(O)(O o) @trusted {
  import std.algorithm : equal;
  import std.exception : enforce;
  import std.string : strip;

  const tag = o.currentTag;
  debug diagnostics ~= "Opening tag `" ~ tag ~ "` in mode " ~ mode.text;
  if (!o.successful) {
    diagnostics ~= o.failMsg(formatFailMsg);
    return o;
  }
  // TODO: https://html.spec.whatwg.org/multipage/parsing.html#tag-open-state
  // Don't push ambiguiously self-closing tags
  if (!selfClosingTags.canFind(tag)) {
    tagStack ~= tag;
    enforce!ParseException(
      o.successful && !tagStack.empty && o.currentTag.equal(tag),
      (debugMode ? o.expectedTag ~ "\n" ~ parserDiagnositics : o.expectedTag).strip
    );
  } else selfClosingTag = tag;

  return o;
}

O tagClose(O)(O o) @trusted {
  import std.array : popBack;
  import std.exception : enforce;

  const tag = o.currentTag;
  debug diagnostics ~= "Closing tag `" ~ tag ~ "` in mode " ~ mode.text;
  // Don't pop ambiguiously self-closing tags
  if (!selfClosingTags.canFind(tag)) {
    const closingTagMismatch = tagStack.empty || tag != tagStack.back;
    if (closingTagMismatch) {
      o.successful = false;
      throw new ParseException(
        "Closing tag mismatch:" ~ (
          tagStack.empty ? "" : "Expected `" ~ tagStack.back ~ "`, but got `" ~ tag ~ '`'
        ) ~ "\n" ~ parserDiagnositics
      );
    }
    else tagStack.popBack();

    if (parent != parent.ownerDocument && parent != parent.ownerDocument.bodyElement) {
      enforce!ParseException(parent.parent !is null, "Incongruous tag stack state: " ~ parent.classinfo.name);
      // parent = parent.parent;
    }
  } else selfClosingTag = null;

  // For an end tag whose tag name is "p"
  if (tag == "p") parent.children_ ~= doc.createElement(tag, parent);

  // https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
  if (mode == InsertionMode.inHead && tag == "head") mode = InsertionMode.afterHead;
  // https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody
  // TODO: if (mode == InsertionMode.inBody && tag == "body") mode = InsertionMode.afterBody;
  // https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-afterbody
  if (mode == InsertionMode.afterBody && tag == "html") mode = InsertionMode.afterAfterBody;

  return o;
}

// TODO: Contribute this back to peggged: https://github.com/PhilippeSigaud/Pegged/wiki/Semantic-Actions#predefined-actions
O discard(O)(O o) {
  if (!o.successful) return o;

  auto p = o.dup;
  p.end = p.begin;
  p.matches = [];
  p.children = null;
  return p;
}

// TODO: Contribute this back to peggged: https://github.com/PhilippeSigaud/Pegged/wiki/Semantic-Actions#predefined-actions
O fuseMatches(O)(O o) {
  auto p = o.dup;
  assert(p.matches.length);
  p.matches = [o.matches.joiner.to!string];
  p.children = null;
  return p;
}

// https://html.spec.whatwg.org/multipage/parsing.html#tag-name-state
O replaceWithUnicodeReplacementCharacter(O)(O o) {
  auto p = o.dup;
  p.name = "unicodeReplacementCharacter";
  assert(p.matches.length);
  // Replace match with U+FFFD REPLACEMENT CHARACTER
  p.matches[0] = '\uFFFD'.to!string;
  p.children = null;
  return p;
}

O appendComment(O)(O o) @safe {
  const content = o.matches.joiner.to!string;
  if (o.successful) parent.children_ ~= new Comment(content, doc);
  return o;
}

O appendText(O)(O o) @safe {
  const content = o.matches.joiner.to!string;
  if (o.successful) parent.children_ ~= new Text(content, doc);
  return o;
}

O appendScript(O)(O o) @safe {
  const content = o.matches.joiner.to!string;
  if (o.successful) parent.children_ ~= new ScriptNode(content, doc);
  return o;
}

O reprocessAs(O)(O o, InsertionMode newMode) {
  const lastMode = mode;
  auto result = o.appendNode(newMode);
  mode = lastMode;
  return result;
}

O appendNode(O)(O o, InsertionMode overrideMode = InsertionMode.none) @safe {
  import std.algorithm : equal;
  import gooey.dom.elements;

  const tag = o.currentTag;
  const currentMode = overrideMode == InsertionMode.none ? mode : overrideMode;
  version(unittest) if (!modes.empty && modes.back != currentMode) modes ~= currentMode;

  switch (currentMode) {
    // https://html.spec.whatwg.org/multipage/parsing.html#the-before-html-insertion-mode
    case InsertionMode.beforeHtml:
      parent = doc.documentElement_;
      if (tag == "html") parent = doc.documentElement_;
      else if (tag == "body") return o.reprocessAs(mode = InsertionMode.inBody);
      else return o.reprocessAs(mode = InsertionMode.beforeHead);
      break;
    // https://html.spec.whatwg.org/multipage/parsing.html#the-before-head-insertion-mode
    case InsertionMode.beforeHead:
      if (tag == "html") break;
      parent = doc.head_;
      return o.reprocessAs(mode = InsertionMode.inHead);
    // https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inhead
    case InsertionMode.inHead:
      if (tag == "html" || tag == "head") break;
      // TODO: Make sure head-level nodes get added here
      else return o.reprocessAs(mode = InsertionMode.afterHead);
    // https://html.spec.whatwg.org/multipage/parsing.html#the-after-head-insertion-mode
    case InsertionMode.afterHead:
      if (tag == "html") break;
      if (tag == "head") return o.reprocessAs(mode = InsertionMode.beforeHead);
      parent = doc.bodyElement;
      return o.reprocessAs(mode = InsertionMode.inBody);
    // https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody
    case InsertionMode.inBody:
      if (tag == "body") {
        parent = doc.bodyElement;
        break;
      } else if (typeid(Document).isBaseOf(parent.classinfo)) parent = doc.bodyElement;
      auto parentNode = parent.nodeName.equal("html") || parent.nodeName.equal("head")
        ? doc.bodyElement
        : parent;
      parentNode.children_ ~= parent = doc.createElement(tag, parentNode);
      debug diagnostics ~= "Appending tag `" ~ tag ~ "` to node `" ~ parentNode.nodeName ~ "`"
        ~ " in mode " ~ currentMode.text ~ ". New parent: " ~ parent.nodeName;
      break;
    case InsertionMode.afterBody:
      return o.reprocessAs(InsertionMode.inBody);
    // case InsertionMode.afterAfterBody:
    //   return o.reprocessAs(InsertionMode.inBody);
    default: assert(0, "Incongruous parser insertion state");
  }
  return o;
}

O appendAttribute(O)(O o) @safe {
  const name = o.matches[0];
  auto parentElement = parentElement();
  parentElement.setAttributeNode(attribute = new Attr(name, parentElement));

  return o;
}

O appendAttributeValue(O)(O o) {
  const value = o.matches.joiner(" ").to!string;
  parentElement.setAttribute(attribute.name, value);

  return o;
}

// Parser error diagnostics
string debugPosition(Position pos) pure {
  return text(pos.line + 1) ~ ":" ~ text(pos.col + 1);
}

string unexpectedError(O)(O o) {
  const position = o.failedChild.empty ? o.position : o.failedChild[0].position;
  return position.debugPosition ~ ": Unexpected error";
}

string expectedTag(O)(O o) {
  import std.algorithm : joiner, map;

  const tag = o.successful
    ? (
      "`" ~ o.fuseMatches.matches.joiner.text ~ "`"
      ~ ", but got `" ~ o.fuseMatches.matches.joiner.text ~ '`'
    ) : "";
  const details = o.successful
    ? (
      "\n\tIs self closing tag: " ~ selfClosingTags.canFind(o.matches[0]).text
      ~ "\n\t" ~ o.fuseMatches.toString
    ) : "\n\t" ~ o.failMsg(formatFailMsg);
  return o.position.debugPosition ~ ": Expected tag" ~ (tag.length ? ' ' ~ tag : "") ~ ':' ~ details;
}

immutable formatFailMsg = delegate (Position pos, string left, string right, const ParseTree pt) @trusted pure {
  const details = `After "` ~ left.text ~ `" at ` ~ pos.debugPosition
    ~ " expected " ~ (pt.matches.length > 0 ? pt.matches[$ - 1].text : "NO MATCH")
    ~ `, but got "` ~ right.text ~ '"';
  debug return details ~ "\n\t" ~ pt.failMsg.replace("\\\"", "");
  else return details;
};

public:

///
class ParseException : Exception {
  import std.exception : basicExceptionCtors;
  ///
  mixin basicExceptionCtors;
}

Document parse(string input) {
  import std.exception : enforce;
  import gooey.dom.elements;

  parent = doc = new Document();
  // Bootstrap the document's root elements
  doc.children_ ~= doc.documentElement_ = new HtmlHtmlElement(doc, doc);
  doc.documentElement_.children_ ~= doc.head_ = new HtmlHeadElement(doc, doc.documentElement_);
  doc.documentElement_.children_ ~= doc._body_ = new HtmlBodyElement(doc, doc.documentElement_);

  // Parse input document, performing node insertion actions from the HTML grammar
  debug diagnostics = [];
  const ast = HTML(input);
  const errorMessage = ast.unexpectedError ~ ": " ~ ast.failMsg(formatFailMsg);
  debug diagnostics ~= "AST: " ~ ast.toString.replace('\n', "\n\t");
  debug enforce!ParseException(ast.successful, errorMessage ~ "\n\n" ~ parserDiagnositics);
  else enforce!ParseException(ast.successful, errorMessage);

  return doc;
}

///
debug string parserDiagnositics() {
  import std.algorithm : equal, joiner, map;
  const modes = "Modes: " ~ modes.map!(mode => mode.text).joiner(" -> ").text;
  debug return [
    modes,
    "Tag stack: " ~ tagStack.text,
    "Parser actions:",
    diagnostics.map!(msg => "- " ~ msg).joiner("\n").text
  ].joiner("\n").text;
  else return [modes, "Tag stack: " ~ tagStack.text].joiner("\n").text;
}

version(unittest) {
  import std.algorithm : equal;
  import std.exception : assertNotThrown;
}

unittest {
  const fragment = parse("<head></head><body><p></body>").assertNotThrown!ParseException;
  assert( fragment.head !is null);
  assert( fragment.bodyElement !is null);
  assert( fragment.bodyElement.nodeName.equal("Body"), "Root node is not body");
  assert(!fragment.bodyElement.children.empty, "Body has no children:\n\n" ~ parserDiagnositics);
  assert(
    fragment.bodyElement.firstChild.nodeName.equal("P"),
    "Root node is not p.\n\n" ~ parserDiagnositics
  );
}

unittest {
  const html =`<div>
    <p>Here comes a list!</p>
    <ul>
        <li class="wanted">one</li>
        <!-- <li>two</li> -->
        <li class="wanted hard">three</li>
        <li id="item-4">four</li>
        <li checked>five</li>
        <li id="item-6">six</li>
    </ul>
    <p>another list</p>
    <ol>
        <li>eins</li>
        <li>zwei</li>
        <li>drei</li>
    <ol>
    <p>have a nice day</p>
</div>`;
  const document = parse(html).assertNotThrown!ParseException;
  assert(document.bodyElement !is null);
  assert(document.bodyElement.nodeName.equal("Body"), "Root node is not body");
  assert(document.bodyElement.children.length > 0, parserDiagnositics);
  assert(
    document.bodyElement.firstChild.nodeName.equal("Div"),
    "Body's first child is not `div`.\n\n" ~ parserDiagnositics
  );
  assert(document.bodyElement.firstChild.children.length > 0, "Main division has no children:\n" ~ parserDiagnositics);
  assert(
    document.bodyElement.firstChild.firstChild.nodeName.equal("P"),
    "Main division's first child is not `p`.\n\n" ~ parserDiagnositics
  );
}
