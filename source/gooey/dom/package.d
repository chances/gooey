/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom;

import std.conv : to;

public import gooey.dom.attributes;
public import gooey.dom.elements;
public import gooey.dom.nodes;

///
class Document : Node {
  package(gooey) Element documentElement_;
  package(gooey) Element _body_;
  package(gooey) Element head_;
  package(gooey) auto readyState_ = DocumentReadyState.loading;
  package(gooey) string title_;

  ///
  this(Element documentElement = null) {
    super(this);

    if (documentElement is null) return;
    assert(documentElement.tagName == "html");
    documentElement = documentElement;
    // TODO: documentElement = parse(documentElement.outerHtml);
  }

  ///
  Element documentElement() const @property @trusted {
    return cast(Element) this.documentElement_;
  }
  /// ditto
  package(gooey) void documentElement(Element value) @property @trusted {
    this.documentElement_ = value;
  }

  ///
  Element head() const @property @trusted {
    return cast(Element) this.head_;
  }

  /// Remarks: Renamed from <a href="https://developer.mozilla.org/en-US/docs/Web/API/Document/body">`body`</a> to avoid conflict with D keyword.
  Element bodyElement() const @property @trusted {
    return cast(Element) this._body_;
  }

  ///
  DocumentReadyState readyState() const @property {
    return this.readyState_;
  }

  ///
  string title() const @property {
    return this.title_;
  }
  /// ditto
  void title(string value) const @property {
    assert(value.length);
    // TODO: https://github.com/chances/surf/blob/d6804df516f8acfff569651634eb9ae59d3ae9dc/xavierHTML/DOM/Document.cs#L65-L84
  }

  ///
  Element createElement(const string tagName) {
    return tagName.createHtmlElement(this).to!Element;
  }
  package(gooey) Element createElement(const string tagName, Node parent) @safe {
    return tagName.createHtmlElement(this, parent).to!Element;
  }
}

///
enum DocumentReadyState {
  ///
  loading,
  ///
  interactive,
  ///
  complete,
}
