import 'dart:math' as math;

import 'package:flutter/widgets.dart';

abstract final class AppScale {
  // Ukuran acuan desain seluruh aplikasi.
  static const double designWidth = 390;
  static const double designHeight = 844;

  // Batas agar ukuran tidak terlalu kecil atau terlalu besar.
  static const double minimumScale = 0.85;
  static const double maximumScale = 2.0;

  static double factor(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final widthScale = size.width / designWidth;
    final heightScale = size.height / designHeight;

    return math
        .min(widthScale, heightScale)
        .clamp(minimumScale, maximumScale)
        .toDouble();
  }

  static double size(BuildContext context, double value) {
    return value * factor(context);
  }
}

// Membuat penulisannya lebih singkat pada halaman/widget.
extension AppScaleContext on BuildContext {
  double ui(double value) => AppScale.size(this, value);
}