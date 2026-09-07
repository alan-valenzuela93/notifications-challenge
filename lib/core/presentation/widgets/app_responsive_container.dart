import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';

class AppResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppResponsiveContainer({
    required this.child,
    super.key,
    this.maxWidth = AppResponsive.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
