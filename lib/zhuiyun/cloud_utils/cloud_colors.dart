import 'package:flutter/material.dart';

class CloudColors {
  static const Color bg = Color(0xFF171723);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color c5E6690 = Color(0xFF5E6690);
  static const Color c242738 = Color(0xFF242738);
  static const Color c5D5D6D = Color(0xFF5D5D6D);
  static const Color c020202 = Color(0xFF020202);
  static const Color c3257FF = Color(0xFF3257FF);
  static const Color c24D4F3 = Color(0xFF24D4F3);
  static const Color c3254FF = Color(0xFF2D79FB);
  static const Color c494D67 = Color(0xFF494D67);
  static const Color c2D79FB = Color(0xFF2D79FB);
  static const Color cEA0000 = Color(0xFFED492E);
  static const Color cA4ADBD = Color(0xFFA4ADBD);
  static const Color c4A4F69 = Color(0xFF4A4F69);
  static const Color c2D3040 = Color(0xFF2D3040);
  static const Color c2F3242 = Color(0xFF2F3242);
  static const Color c40455D = Color(0xFF40455D);
  static const Color c63483D = Color(0xFF63483D);
  static const Color cBA987A = Color(0xFFBA987A);
  static const Color c32CD32 = Color(0xFF32CD32);

  // Semantic color mappings for zhuiyun pages.
  static Color appBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color textOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  static Color overlaySurface(BuildContext context) =>
      Theme.of(context).colorScheme.inverseSurface;

  static Color overlayOnSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onInverseSurface;

  static Color success(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color brandPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color brandSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color link(BuildContext context) => brandPrimary(context);

  static Color warning(BuildContext context) =>
      Theme.of(context).colorScheme.errorContainer;

  static Color muted(BuildContext context) => textSecondary(context);
}
