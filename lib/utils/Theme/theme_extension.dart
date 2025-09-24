import 'package:flutter/material.dart';

extension ThemeContextColors on BuildContext {
  Color get mainFontColor =>
      Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  Color get placeholderColor => Theme.of(this).hintColor;

  Color get hintColor => Theme.of(this).hintColor;

  Color get fieldColor =>
      Theme.of(this).inputDecorationTheme.fillColor ??
      (Theme.of(this).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF5F7F9));

  Color get lineColor => Theme.of(this).dividerColor;

  Color get buttonColor => Theme.of(this).colorScheme.primary;

  Color get buttonTextColor => Theme.of(this).colorScheme.onPrimary;

  Color get borderColor =>
      Theme.of(this).colorScheme.primary.withOpacity(0.3);

  Color get successColor =>
      Theme.of(this).colorScheme.secondaryContainer.withOpacity(0.85);

  Color get failedColor =>
      Theme.of(this).colorScheme.error.withOpacity(0.85);

  Color get cardColor => Theme.of(this).cardColor;

  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
}
