/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey.rasterization;

import descartes;
import std.conv : to;

///
interface Rasterizer {}

// TODO: Model objects for rasterized painting
struct Rect {
	float top;
	float right;
	float bottom;
	float left;

	float width() inout {
		return (right - left).to!float;
	}

	float height() inout {
		return (bottom - top).to!float;
	}
}
