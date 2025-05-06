import 'package:flutter/material.dart';

// extension ContextExtension on BuildContext {
//   MediaQueryData get mediaQuery => MediaQuery.of(this);
//   TextTheme get textTheme => Theme.of(this).textTheme;
// }

extension MediaQueryExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get height => mediaQuery.size.height;
  double get width => mediaQuery.size.width;

  double dynamicWidth(double val) => width * val;
  double dynamicHeight(double val) => height * val;
  double fontSizeBasedScreen(double val) => height * 0.025 * val;
}
