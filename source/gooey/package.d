/// Authors: Chance Snow
/// Copyright: Copyright © 2021 Chance Snow. All rights reserved.
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

  /// Size of this Surface, in pixels.
  Size dimensions() @property const {
    return _size;
  }
}

unittest {
  import bindbc.blend2d;

  BLResult r;
  BLImageCore img;
  BLContextCore ctx;
  BLGradientCore gradient;

  r = blImageInitAs(&img, 256, 256, BL_FORMAT_PRGB32);
  if (r != BL_SUCCESS)
      assert(false);

  r = blContextInitAs(&ctx, &img, null);
  if (r != BL_SUCCESS)
      assert(false);

  BLLinearGradientValues values = { 0, 0, 256, 256 };
  r = blGradientInitAs(&gradient, BL_GRADIENT_TYPE_LINEAR, &values, BL_EXTEND_MODE_PAD, null, 0, null);
  if (r != BL_SUCCESS)
      assert(false);

  blGradientAddStopRgba32(&gradient, 0.0, 0xFFFFFFFFU);
  blGradientAddStopRgba32(&gradient, 0.5, 0xFFFFAF00U);
  blGradientAddStopRgba32(&gradient, 1.0, 0xFFFF0000U);

  blContextSetFillStyleObject(&ctx, &gradient);
  blContextFillAll(&ctx);
  blGradientDestroy(&gradient);

  BLCircle circle;
  circle.cx = 128;
  circle.cy = 128;
  circle.r = 64;

  blContextSetCompOp(&ctx, BL_COMP_OP_EXCLUSION);
  blContextSetFillStyleRgba32(&ctx, 0xFF00FFFFU);
  blContextFillGeometry(&ctx, BL_GEOMETRY_TYPE_CIRCLE, &circle);

  blContextEnd(&ctx);
  blImageDestroy(&img);
}
