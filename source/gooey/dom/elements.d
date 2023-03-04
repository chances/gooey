/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom.elements;

import gooey.dom : Document;
import gooey.dom.nodes : Node;
import gooey.dom.attributes : Attr, Attribute;
import std.typecons : Flag, No, Yes;

@safe:

///
abstract class Element : Node {
  import gooey.dom.attributes : assocArray;
  import std.string : capitalize;

  protected bool _tabStop;

  package(gooey) this(string tagName) {
    super(tagName.capitalize);
  }
  package(gooey) this(
    string tagName, Document owner = null, Node parent = null,
    bool tabStop = No.tabStop
  ) @safe {
    super(tagName.capitalize, owner, parent);
    _tabStop = tabStop;
  }

  ///
  string tagName() const @property {
    return this.nodeName;
  }

  ///
  bool hasAttribute(string name) const {
    import std.algorithm : canFind;
    enum findAttribute = (const Attribute attr, string name) => attr.name == name;
    return super.attributes_.canFind!findAttribute(name);
  }

  ///
  string getAttribute(string attributeName) const {
    import std.range : back;
    return this.attributes.assocArray.get(attributeName, [""]).back;
  }

  ///
  Attr getAttributeNode(string attrName) const @trusted {
    return cast(Attr) new Attr(attrName, cast(Element) this, this[attrName]);
  }

  ///
  void setAttribute(string name, string value) {
    import gooey.dom.attributes : Attribute;
    import std.algorithm : countUntil;

    if (!hasAttribute(name)) super.attributes_ ~= Attribute(name, value);
    const attributeIndex = super.attributes_.countUntil!(attr => attr.name == name);
    super.attributes_[attributeIndex] = Attribute(name, value);
  }

  ///
  void setAttributeNode(Attr attribute) {
    setAttribute(attribute.name, attribute.value);
  }

  /// Retrieve an attribute given its `name`.
  string opIndex(string name) const {
    const values = attributes.assocArray.get(name, []);
    if (!values.length) return null;
    return values[0];
  }

  ///
  string id() const @property {
    return this["id"];
  }

  ///
  string className() const @property {
    return this["class"];
  }

  ///
  string[] classList() const @property {
    import std.algorithm : filter, joiner, splitter;
    import std.array : array;
    import std.conv : to;
    import std.string : strip;

    auto classes = attributes.assocArray.get("class", []).joiner(" ").array.to!string;
    return classes.splitter(' ').filter!(a => a.strip.length).array;
  }

  ///
  string innerText() const @property {
    // TODO: Implement inner text algorithm https://html.spec.whatwg.org/multipage/dom.html#dom-innertext
    return textContent;
  }

  ///
  Element[] elementsByTagName(string qualifiedName) {
    assert(qualifiedName.length || false, "Not implemented.");
    return [];
  }

  ///
  bool tabStop() @property const {
    return _tabStop;
  }
}

unittest {
  import gooey.dom.nodes : Text;
  import std.algorithm : equal;

  auto span = new HtmlSpanElement();
  assert(span.id == null);
  assert(span.hasAttribute("id") == false);
  assert(span.tabStop == false);
  assert(new HtmlButtonElement().tabStop);

  auto body_ = new HtmlBodyElement();
  body_.appendChild(span);
  assert(body_.firstChild.parentElement !is null);

  body_ = new HtmlBodyElement();
  body_.children_ ~= [span, new Text("foo")];
  assert(body_.lastChild.textContent.equal("foo"));
}

///
class HtmlElement : Element {
  package(gooey) this(
    string tagName, Document owner = null, Node parent = null,
    bool tabStop = No.tabStop
  ) @safe {
    super(tagName, owner, parent, tabStop);
  }
}

///
static htmlElementsWithPlainInterfaces = [
  "dd", "dt", "ruby", "rp", "rt", "span", "em", "mark"
];

// TODO: mark tag aria attributes, e.g. https://lists.whatwg.org/pipermail/whatwg-whatwg.org/2010-December/071719.html

alias HtmlHtmlElement = HtmlElementOf!"html";
alias HtmlHeadElement = HtmlElementOf!"head";
alias HtmlBaseElement = HtmlElementOf!"base";
alias HtmlBasefontElement = HtmlElementOf!"basefont";
alias HtmlBgsoundElement = HtmlElementOf!"bgsound";
alias HtmlLinkElement = HtmlElementOf!"link";
alias HtmlMetaElement = HtmlElementOf!"meta";
alias HtmlTitleElement = HtmlElementOf!"title";
alias HtmlNoscriptElement = HtmlElementOf!"noscript";
alias HtmlNoframesElement = HtmlElementOf!"noframes";
alias HtmlStyleElement = HtmlElementOf!"style";
alias HtmlTemplateElement = HtmlElementOf!"template";
alias HtmlBodyElement = HtmlElementOf!"body";
alias HtmlBrElement = HtmlElementOf!"br";
alias HtmlAnchorElement = HtmlElementOf!"a";
alias HtmlDivElement = HtmlElementOf!"div";
alias HtmlSpanElement = HtmlElementOf!"span";
alias HtmlEmbedElement = HtmlElementOf!"embed";
alias HtmlFormElement = HtmlElementOf!"form";
alias HtmlInputElement = HtmlElementOf!"input";
alias HtmlButtonElement = HtmlElementOf!("button", Yes.tabStop);
alias HtmlOlistElement = HtmlElementOf!"ol";
alias HtmlUlistElement = HtmlElementOf!"ul";
alias HtmlLiElement = HtmlElementOf!"li";
alias HtmlOptGroupElement = HtmlElementOf!"optgroup";
alias HtmlOptionElement = HtmlElementOf!"option";
alias HtmlParagraphElement = HtmlElementOf!"p";
alias HtmlPreElement = HtmlElementOf!"pre";
alias HtmlTableElement = HtmlElementOf!"table";
alias HtmlTableRowElement = HtmlElementOf!"tr";
alias HtmlUnknownElement = HtmlElementOf!null;

/// Provides an interface for manipulating the layout and presentation of sections, i.e. headers, footers, and bodies, in an HTML table.
class HtmlTableSectionElement : HtmlElement {
  package(gooey) this(string tagName, Document owner = null, Node parent = null) {
    assert(tagName == "thead" || tagName == "tbody" || tagName == "tfoot");
    super(tagName, owner, parent);
  }
}

/// Provides an interface for manipulating the layout and presentation of table cells, either header or data cells, in an HTML table.
class HtmlTableCellElement : HtmlElement {
  package(gooey) this(string tagName, Document owner = null, Node parent = null) {
    assert(tagName == "th" || tagName == "td");
    super(tagName, owner, parent);
  }
}

/// Allows authors to include dynamic script and data blocks in their documents.
/// See_Also: https://html.spec.whatwg.org/multipage/scripting.html#htmlscriptelement
class HtmlScriptElement : HtmlElement {
  package(gooey) this(Document owner = null, Node parent = null) {
    super("script", owner, parent);
  }
}

package class HtmlElementOf(string staticTagName, Flag!"tabStop" staticTabStop = No.tabStop) : HtmlElement {
  ///
  this() @safe { super(staticTagName, null, null, staticTabStop); }
  package(gooey) @safe this(Document owner = null, Node parent = null) {
    super(staticTagName, owner, parent, staticTabStop);
  }
}

private static htmlElementInterfaces = [

];

/// Gets the type ID of a HTML element's DOM interface given a HTML tag name.
package(gooey.dom) TypeInfo_Class htmlElementInterface(string tagName) @property {
  import std.algorithm : canFind;

  if (htmlElementsWithPlainInterfaces.canFind(tagName)) return typeid(HtmlUnknownElement);
  switch (tagName) {
    case "html":      return typeid(HtmlHtmlElement);
    case "head":      return typeid(HtmlHeadElement);
    case "base":      return typeid(HtmlBaseElement);
    case "basefont":  return typeid(HtmlBasefontElement);
    case "bgsound":   return typeid(HtmlBgsoundElement);
    case "link":      return typeid(HtmlLinkElement);
    case "meta":      return typeid(HtmlMetaElement);
    case "title":     return typeid(HtmlTitleElement);
    case "noscript":  return typeid(HtmlNoscriptElement);
    case "noframes":  return typeid(HtmlNoframesElement);
    case "style":     return typeid(HtmlStyleElement);
    case "script":    return typeid(HtmlScriptElement);
    case "template":  return typeid(HtmlTemplateElement);
    case "body":      return typeid(HtmlBodyElement);
    case "br":        return typeid(HtmlBrElement);
    case "a":         return typeid(HtmlAnchorElement);
    case "div":       return typeid(HtmlDivElement);
    case "span":      return typeid(HtmlSpanElement);
    case "embed":     return typeid(HtmlEmbedElement);
    case "form":      return typeid(HtmlFormElement);
    case "input":     return typeid(HtmlInputElement);
    case "button":    return typeid(HtmlButtonElement);
    case "ol":        return typeid(HtmlOlistElement);
    case "ul":        return typeid(HtmlUlistElement);
    case "li":        return typeid(HtmlLiElement);
    case "optgroup":  return typeid(HtmlOptGroupElement);
    case "option":    return typeid(HtmlOptionElement);
    case "p":         return typeid(HtmlParagraphElement);
    case "pre":       return typeid(HtmlPreElement);
    case "table":     return typeid(HtmlTableElement);
    case "tr":        return typeid(HtmlTableRowElement);
    default:          return typeid(HtmlUnknownElement);
  }
}

package(gooey) HtmlElement createHtmlElement(const string tagName, Document owner = null, Node parent = null) @safe {
  import std.algorithm : canFind;

  if (htmlElementsWithPlainInterfaces.canFind(tagName)) return new HtmlElement(tagName, owner, parent);
  switch (tagName) {
    case "html":      return new HtmlHtmlElement(owner, parent);
    case "head":      return new HtmlHeadElement(owner, parent);
    case "base":      return new HtmlBaseElement(owner, parent);
    case "basefont":  return new HtmlBasefontElement(owner, parent);
    case "bgsound":   return new HtmlBgsoundElement(owner, parent);
    case "link":      return new HtmlLinkElement(owner, parent);
    case "meta":      return new HtmlMetaElement(owner, parent);
    case "title":     return new HtmlTitleElement(owner, parent);
    case "noscript":  return new HtmlNoscriptElement(owner, parent);
    case "noframes":  return new HtmlNoframesElement(owner, parent);
    case "style":     return new HtmlStyleElement(owner, parent);
    case "script":    return new HtmlScriptElement(owner, parent);
    case "template":  return new HtmlTemplateElement(owner, parent);
    case "body":      return new HtmlBodyElement(owner, parent);
    case "br":        return new HtmlBrElement(owner, parent);
    case "a":         return new HtmlAnchorElement(owner, parent);
    case "div":       return new HtmlDivElement(owner, parent);
    case "span":      return new HtmlSpanElement(owner, parent);
    case "embed":     return new HtmlEmbedElement(owner, parent);
    case "form":      return new HtmlFormElement(owner, parent);
    case "input":     return new HtmlInputElement(owner, parent);
    case "button":    return new HtmlButtonElement(owner, parent);
    case "ol":        return new HtmlOlistElement(owner, parent);
    case "ul":        return new HtmlUlistElement(owner, parent);
    case "li":        return new HtmlLiElement(owner, parent);
    case "optgroup":  return new HtmlOptGroupElement(owner, parent);
    case "option":    return new HtmlOptionElement(owner, parent);
    case "p":         return new HtmlParagraphElement(owner, parent);
    case "pre":       return new HtmlPreElement(owner, parent);
    case "table":     return new HtmlTableElement(owner, parent);
    case "tr":        return new HtmlTableRowElement(owner, parent);
    default: return new HtmlUnknownElement(owner, parent);
  }
}
