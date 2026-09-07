import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
}

abstract final class AppResponsive {
  static const double maxContentWidth = 960;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
  }

  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
  }

  static double horizontalPadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width >= AppBreakpoints.expanded) {
      return 32;
    }
    if (width >= AppBreakpoints.medium) {
      return 24;
    }
    return width < 360 ? 8 : 12;
  }

  static double spacing(BuildContext context, double value) {
    final double width = MediaQuery.sizeOf(context).width;
    final double factor = (width / 390).clamp(0.85, 1.2);
    return value * factor;
  }

  static double iconSize(BuildContext context, double value) {
    return spacing(context, value).clamp(value * 0.9, value * 1.15);
  }

  static double textScaleFactor(BuildContext context) {
    return (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1, 2);
  }

  static double filterBarHeight(BuildContext context) {
    final double extraHeight = (textScaleFactor(context) - 1) * 28;
    return 56 + extraHeight;
  }
}
