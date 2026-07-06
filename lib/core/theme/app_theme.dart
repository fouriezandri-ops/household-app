import 'package:flutter/material.dart';

/// Material 3 theme shared by both light and dark mode. A single seed color
/// keeps the two schemes visually consistent without hand-picking every
/// shade twice.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF3A6351);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
