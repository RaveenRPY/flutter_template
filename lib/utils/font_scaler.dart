
import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveFontScaler {
  static double scaleFont(
      BuildContext context, {
        required double baseFontSize, // Design-time font size in logical pixels
        double minScale = 0.85,
        double maxScale = 1.25,
      }) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = mediaQuery.size.width;
    final double height = mediaQuery.size.height;
    final double devicePixelRatio = mediaQuery.devicePixelRatio;

    // You can use width * height or diagonal size as the factor
    double scaleFactor = sqrt((width * height) / (375.0 * 812.0)); // Based on iPhone X size

    // Also consider pixel density (optional tweak)
    scaleFactor *= (2.0 / devicePixelRatio);

    // Clamp scaling to avoid extreme values
    scaleFactor = scaleFactor.clamp(minScale, maxScale);

    return baseFontSize * scaleFactor;
  }
}