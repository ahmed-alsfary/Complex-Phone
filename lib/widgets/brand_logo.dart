import 'package:flutter/material.dart';

import '../core/theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 72,
    this.padding = 10,
    this.backgroundColor,
    this.borderRadius = 22,
    this.showBorder = false,
  });

  final double size;
  final double padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: AppTheme.border)
            : Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Image.asset(
        'assets/branding/logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
