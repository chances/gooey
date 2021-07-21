/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom;

import std.conv : to;

///
abstract class Node {
  ///
  Node parent;
  ///
  Node[] children;

  ///
  this() {}
  ///
  this(Node[] children) {
    import std.algorithm : each;

    this.children = children;
    this.children.each!(node => node.parent = this);
  }

  ///
  const(Node) firstChild() @property const {
    if (children.length == 0) return null;
    return children[0];
  }

  ///
  const(Node) lastChild() @property const {
    import std.range : tail;
    if (children.length == 0) return null;
    return children.tail(1)[0];
  }

  ///
  const(Element) parentElement() @property const {
    return parent !is null && typeid(Element).isBaseOf(parent.classinfo) ? parent.to!(const Element) : null;
  }

  ///
  string textContent() @property const {
    import std.algorithm : map, fold;

    return children.map!(node => {
      if (typeid(TextNode).isBaseOf(node.classinfo)) return node.to!(const TextNode).data;
      else return node.textContent;
    }()).fold!((a, b) => a ~ b)("");
  }
}

///
class TextNode : Node {
  ///
  string data;

  ///
  this(string data) {
    this.data = data;
  }

  ///
  override string textContent() @property const {
    return data ~ super.textContent;
  }
}

unittest {
  import std.algorithm : equal;

  auto foo = new TextNode("foo");
  assert(foo.textContent.equal("foo"));

  auto bar = new TextNode("bar");
  foo.children ~= bar;
  assert(foo.textContent.equal("foobar"));

  assert(new BodyElement([foo, bar]).textContent.equal("foobar"));
  assert(new BodyElement([foo, bar, new SpanElement()]).textContent.equal("foobar"));
  assert(new BodyElement([
    new SpanElement([new TextNode("fizz"), new TextNode("buzz")])
  ]).textContent.equal("fizzbuzz"));
}

///
abstract class Element : Node {
  ///
  const(char)[] tagName;
  ///
  string[string] attributes;
  private Element[] ancestors_;
  protected bool tabStop_;

  ///
  this(string tagName, Node[] children) {
    super(children);
    this.tagName = tagName;
  }

  ///
  bool hasAttribute(string name) const {
    return (name in attributes) !is null;
  }

  ///
  auto id() @property const {
    return "id" in attributes;
  }

  bool tabStop() @property const {
    return tabStop_;
  }
}

import std.typecons : Flag, No, Yes;

package mixin template element(string tagName, Flag!"tabStop" tabStop = No.tabStop) {
  import std.string : capitalize, format;
  mixin(`class %sElement : Element {
    this() { this([]); }
    this(Node[] children) {
      super(tagName.to!string, children);
      this.tabStop_ = %s;
    }
  }`.format(tagName.capitalize, tabStop.to!bool.to!string));
}

mixin element!"html";
mixin element!"head";
mixin element!"body";
mixin element!"span";
mixin element!("button", Yes.tabStop);

unittest {
  import std.algorithm : equal;

  auto span = new SpanElement();
  assert(span.id == null);
  assert(span.hasAttribute("id") == false);
  assert(span.tabStop == false);
  assert(new ButtonElement().tabStop);

  assert(new BodyElement([span]).firstChild.parentElement !is null);
  assert(new BodyElement([span, new TextNode("foo")]).lastChild.textContent.equal("foo"));
}
