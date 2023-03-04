/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.dom.nodes;

import gooey.dom : Document;
import gooey.dom.elements : Element;
import gooey.dom.attributes : Attribute;

@safe:

// TODO: Refactor this into a scripting module
package class JsError : Exception {
  import std.exception : basicExceptionCtors;
  ///
  mixin basicExceptionCtors;
}
///
class TypeError : Error {
  import std.exception : basicExceptionCtors;
  ///
  mixin basicExceptionCtors;
}

/// See_Also: https://webidl.spec.whatwg.org/#idl-DOMException
class DomException : Exception {
  const string name;
  const ushort code;

  /// Params:
  ///   name =
  ///   code =
  ///   msg  = The message for the exception.
  ///   file = The file where the exception occurred.
  ///   line = The line number where the exception occurred.
  ///   next = The previous exception in the chain of exceptions, if any.
  this(
    string name, ushort code = 0, string msg = null, string file = __FILE__, size_t line = __LINE__
  ) @nogc @safe pure nothrow {
    super(msg, file, line);
    this.name = name;
    this.code = code;
  }

  /// Params:
  ///   name =
  ///   code =
  ///   msg  = The message for the exception.
  ///   next = The previous exception in the chain of exceptions.
  ///   file = The file where the exception occurred.
  ///   line = The line number where the exception occurred.
  this(
    DomException next, string name, ushort code = 0, string msg = null, string file = __FILE__, size_t line = __LINE__
  ) @nogc @safe pure nothrow {
    super(msg, file, line, next);
    this.name = name;
    this.code = code;
  }

  static ushort INDEX_SIZE_ERR = 1;
  static ushort DOMSTRING_SIZE_ERR = 2;
  static ushort HIERARCHY_REQUEST_ERR = 3;
  static ushort WRONG_DOCUMENT_ERR = 4;
  static ushort INVALID_CHARACTER_ERR = 5;
  static ushort NO_DATA_ALLOWED_ERR = 6;
  static ushort NO_MODIFICATION_ALLOWED_ERR = 7;
  static ushort NOT_FOUND_ERR = 8;
  static ushort NOT_SUPPORTED_ERR = 9;
  static ushort INUSE_ATTRIBUTE_ERR = 10;
  static ushort INVALID_STATE_ERR = 11;
  static ushort SYNTAX_ERR = 12;
  static ushort INVALID_MODIFICATION_ERR = 13;
  static ushort NAMESPACE_ERR = 14;
  static ushort INVALID_ACCESS_ERR = 15;
  static ushort VALIDATION_ERR = 16;
  static ushort TYPE_MISMATCH_ERR = 17;
  static ushort SECURITY_ERR = 18;
  static ushort NETWORK_ERR = 19;
  static ushort ABORT_ERR = 20;
  static ushort URL_MISMATCH_ERR = 21;
  static ushort QUOTA_EXCEEDED_ERR = 22;
  static ushort TIMEOUT_ERR = 23;
  static ushort INVALID_NODE_TYPE_ERR = 24;
  static ushort DATA_CLONE_ERR = 25;
}

///
abstract class Node {
  import std.conv : to;

  private string nodeName_;
  package(gooey.dom) Attribute[] attributes_ = [];
  private Node parent_;
  package(gooey) Node[] children_ = [];
  private Document ownerDocument_;

  ///
  this() { assert(0, "Use `Document.createElement`"); }
  ///
  package(gooey.dom) this(Document owner, Node parent = null) {
    this(null, owner, parent);
  }
  ///
  package(gooey.dom) this(string nodeName, Document owner = null, Node parent = null) {
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
  Element parentElement() const @property @trusted {
    if (this.parent_ is null || !typeid(Element).isBaseOf(this.parent_.classinfo)) return null;
    return cast(Element) this.parent_;
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
  string textContent() @trusted @property const {
    import std.algorithm : map, fold;

    if (typeid(Text).isBaseOf(this.classinfo)) return (cast(Text) this).data;

    assert(children_ !is null);
    return children_.map!(a => a.textContent).fold!((a, b) => a ~ b)("");
  }

  /// Retrieve the child `Node` at the given index.
  Node opIndex(size_t index) {
    return this.children_[index];
  }

  /// Adds a `node` to the end of the list of children of this node.
  /// Returns: The appended node.
  /// Remarks:
  /// If the given child is a reference to an existing node in the document, the `node` is moved from its current position to the new position.
  /// There is no requirement to remove the node from its parent node before appending it to some other node.
  Node appendChild(Node node) {
    // https://dom.spec.whatwg.org/#concept-node-append
    // https://dom.spec.whatwg.org/#concept-node-pre-insert
    children_ ~= node;
    if (node.parent !is null) node.parent.removeChild(node);
    node.parent_ = this;
    return node;
  }

  /// Removes a child `node` from this node.
  /// Returns: The removed node.
  /// Throws: `TypeError` if the `child` is `null`.
  /// Throws: NotFoundError:`DomException` if the `child` is not a child of the node.
  Node removeChild(Node node) @trusted {
    import std.exception : enforce;
    import std.algorithm : any, remove, SwapStrategy;

    enforce!TypeError(node !is null);
    if (!this.children_.any!(n => n.isEqualNode(node))())
      throw new DomException("NotFoundError", DomException.NOT_FOUND_ERR);
    this.children_ = this.children_.remove!(x => x == node, SwapStrategy.stable);
    node.parent_ = null;
    return node;
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
  ///
  static string data;
}

///
class Comment : Node, CharacterData {
  ///
  static string data;

  ///
  this(string data, Document owner = null) {
    super(owner);
    this.data = data;
  }
}

///
@safe class Text : Node, CharacterData {
  ///
  string data;

  ///
  this(string contents, Document owner = null) {
    super(owner);
    this.data = contents;
  }
}

unittest {
  import gooey.dom.elements : HtmlBodyElement, HtmlSpanElement;
  import std.algorithm : equal;
  import std.conv : to;
  import std.exception : assertThrown, assertNotThrown;

  auto foo = new Text("foo");
  assert(foo.isEqualNode(foo));
  assert(foo.textContent.equal("foo"), `"` ~ foo.textContent ~ `"`);

  // Text node children of text nodes is not considered in `Node.textContent`
  auto bar = new Text("bar");
  foo.children_ ~= bar;
  assert(!foo.isEqualNode(bar));
  assert( foo.textContent.equal("foo"), `"` ~ foo.textContent ~ `"`);

  auto body_ = new HtmlBodyElement();
  body_.children_ ~= [foo, bar];
  assert(body_.hasChildNodes);
  assert(body_.to!Node[0].isEqualNode(foo));
  assert(body_.textContent.equal("foobar"), `"` ~ body_.textContent ~ `"`);

  body_ = new HtmlBodyElement();
  body_.children_ ~= [foo, bar, new HtmlSpanElement()];
  assert(body_.textContent.equal("foobar"), `"` ~ body_.textContent ~ `"`);
  assertNotThrown!DomException(body_.removeChild(foo));
  assert(body_.textContent.equal("bar"), `"` ~ body_.textContent ~ `"`);

  body_ = new HtmlBodyElement();
  auto span = new HtmlSpanElement();
  span.children_ ~= [new Text("fizz"), new Text("buzz")];
  body_.children_ ~= span;
  assert(body_.textContent.equal("fizzbuzz"), `"` ~ body_.textContent ~ `"`);
  assertThrown!DomException(body_.removeChild(foo));
}

///
class ScriptNode : Node {
  ///
  static string contents;

  ///
  this(string contents, Document owner = null) {
    super("script", owner);
    this.contents = contents;
  }
}

///
class StyleNode : Node {
  ///
  static string contents;

  ///
  package(gooey) this(string contents, Document owner = null) {
    super("style", owner);
    this.contents = contents;
  }
}
