/// Authors: Chance Snow
/// Copyright: Copyright © 2022 Chance Snow. All rights reserved.
/// License: MIT License
module gooey;

public import gooey.math;

/// Bitmap pixel format.
enum ImageFormat {
  rgba8_sRgb,
  bgra8_sRgb
}

///
public class Surface {
  private ImageFormat _format;
  private Size _size;
  private ubyte[] _data;

  // Pixel format of this Surface's underlying bitmap.
  ImageFormat format() @property const {
    return _format;
  }

  /// Size of this Surface, in logical pixels.
  Size dimensions() @property const {
    return _size;
  }
}
