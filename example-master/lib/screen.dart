import 'package:flutter/material.dart';

class Screen {
  Size size;
  double textScale;
  Screen({@required this.size, this.textScale});
  double get height => size.height;
  double get width => size.width;
  double get aspectRatio => size.aspectRatio;
  double convert(double input, double from) {
    return (input / from) * from;
  }
}
