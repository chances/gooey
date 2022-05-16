/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom.nodes;

import gooey.dom : Document;
import gooey.dom.elements : Element;
import gooey.dom.attributes : Attribute;

@safe:

///
abstract class Node {
  private string nodeName_;
  package(gooey.dom) Attribute[] attributes_;
  private Node parent_;
  package(gooey) Node[] children_;
  private Document ownerDocument_;

  ///
  this() { assert(0, "Use `Document.createElement`"); }
  ///
  package(gooey.dom) this(string nodeName = null) {
    this.nodeName_ = nodeName;
  }
  ///
  package(gooey.dom) this(Document owner, Node parent = null) {
    this(null, owner, parent);
  }
  ///
  package(gooey.dom) this(string nodeName, Document owner, Node parent = null) {
    this.nodeName_ = nodeName;
    this.ownerDocument_ = owner;
    this.parent_ = parent;
  }

  ///
  string nodeName() const @property {
    return this.nodeName_;
  }

  ///
  const(Attribute[]) attributes() const @property {
    return this.attributes_;
  }

  ///
  Document ownerDocument() const @property @trusted {
    return cast(Document) this.ownerDocument_;
  }

  ///
  Node parent() const @property @trusted {
    return cast(Node) this.parent_;
  }

  ///
  gooey.dom.Element parentElement() const @property @trusted {
    import std.conv : to;

    if (this.parent_ is null || !typeid(Element).isBaseOf(this.parent_.classinfo)) return null;
    return (cast(Node) this.parent_).to!Element;
  }

  bool hasChildNodes() const @property {
    return this.children_.length > 0;
  }

  ///
  Node[] children() const @property @trusted {
    return cast(Node[]) this.children_;
  }

  ///
  Node firstChild() const @property @trusted {
    if (this.children_.length == 0) return null;
    return cast(Node) this.children_[0];
  }

  ///
  Node lastChild() const @property @trusted {
    if (this.children_.length == 0) return null;
    return cast(Node) this.children_[$ - 1];
  }

  ///
  Node nextSibling() const @property {
    assert(0, "Not implemented.");
  }

  ///
  string textContent() const @property {
    // TODO: https://github.com/chances/surf/blob/d6804df516f8acfff569651634eb9ae59d3ae9dc/xavierHTML/DOM/Nodes/Node.cs#L29-L45
    assert(0, "Not implemented.");
  }

  /// Retreive the child `Node` at the given index.
  Node opIndex(size_t index) {
    return this.children_[index];
  }

  /// Whether this node is equivalent to the given `other` node.
  ///
  /// Two nodes are equal when they have the same:
  /// $(UL
  ///   $(LI type, e,g. `nodeName` or ``)
  ///   $(LI defining characteristics, e.g. for elements: IDs, number of children, etc.)
  ///   $(LI attributes)
  ///   $(LI etc.)
  /// )
  /// The specific set of data points that must match varies depending on the types of the nodes.
  /// See_Also: <a href="https://dom.spec.whatwg.org/#dom-node-isequalnode">isEqualNode</a> (WHATWG DOM Living Standard)
  bool isEqualNode(Node other) {
    import std.algorithm : map, reduce;
    import std.range : enumerate;
    import std.traits : fullyQualifiedName;
    import std.typecons : Tuple;
    import gooey.dom.attributes : Attr;

    // https://dom.spec.whatwg.org/#concept-node-equals
    if (this.children_.length != other.children_.length) return false;

    auto implIdenticalInterface = this.implementsInterface!Node(other);
    const className = this.classinfo.name;
    // TODO: Compare nodeName and attributes for Elements
    if (className == fullyQualifiedName!Element) implIdenticalInterface &= this.implementsInterface!Element(other);
    if (className == fullyQualifiedName!Attr) implIdenticalInterface &= this.implementsInterface!Attr(other);
    // TODO: Compare content for Text and Comment nodes
    if (className == fullyQualifiedName!Text) implIdenticalInterface &= this.implementsInterface!Text(other);
    if (className == fullyQualifiedName!Comment) implIdenticalInterface &= this.implementsInterface!Comment(other);
    if (!implIdenticalInterface) return false;

    if (this.children_.length == 0) return true;
    alias Enumerable = Tuple!(ulong, "index", Node, "value");
    const childrenMatch = this.children_.enumerate
      .map!((Enumerable child) => child.value.isEqualNode(other.children_[child.index]))
      .reduce!((a, b) => a && b);
    return childrenMatch;
  }
}

/// See_Also: https://dom.spec.whatwg.org/#concept-node-equals
private bool implementsInterface(T)(Node a, Node b) {
  return typeid(T).isBaseOf(a.classinfo) && typeid(T).isBaseOf(b.classinfo);
}

///
interface CharacterData {
  static string data;
}

///
class Comment : Node, CharacterData {
  static string data;

  ///
  this(string data, Document owner = null) {
    super(owner);
    this.data = data;
  }
}

///
@safe class Text : Node, CharacterData {
  static string data;

  ///
  this(string contents, Document owner = null) {
    super(owner);
    this.data = contents;
  }
}

///
class ScriptNode : Node {
  static string contents;

  ///
  this(string contents, Document owner = null) {
    super("script", owner);
    this.contents = contents;
  }
}

///
class StyleNode : Node {
  static string contents;

  ///
  package(gooey) this(string contents, Document owner = null) {
    super("style", owner);
    this.contents = contents;
  }
}
