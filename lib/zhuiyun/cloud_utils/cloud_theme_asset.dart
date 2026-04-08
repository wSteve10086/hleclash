import 'package:flutter/material.dart';

class CloudThemeAsset extends StatelessWidget {
  const CloudThemeAsset(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.tintInLight = false,
    this.tintInDark = false,
    this.lightColor,
    this.darkColor,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool tintInLight;
  final bool tintInDark;
  final Color? lightColor;
  final Color? darkColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldTint = isDark ? tintInDark : tintInLight;
    final Color? tintColor = isDark
        ? (darkColor ?? Theme.of(context).colorScheme.onSurface)
        : (lightColor ?? Theme.of(context).colorScheme.onSurface);
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      color: shouldTint ? tintColor : null,
      colorBlendMode: shouldTint ? BlendMode.srcIn : null,
    );
  }
}
