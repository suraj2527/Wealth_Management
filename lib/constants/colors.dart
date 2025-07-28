// // import 'package:flutter/material.dart';

// // class AppColors {
// //   static const Color buttonColor = Color.fromRGBO(105, 65, 198, 1);
// //   static const Color buttonTextColor = Color.fromRGBO(255, 255, 255, 1);

// //   static const Color placeholderColor = Color.from(alpha: 1, red: 0.667, green: 0.667, blue: 0.667);
// //   static const Color mainFontColor = Color.fromRGBO(0, 0, 0, 1);
// //   static const Color graphcolor = Color.fromRGBO(151, 143, 237, 1);
// //   static const Color menudrawer = Color.fromRGBO(105, 65, 198, 1);
// //   static const Color fieldcolor = Color.fromRGBO(245, 247, 249, 1);
// //   static const Color linecolor = Colors.grey;
// //   static const Color bordercolor = Color.fromRGBO(105, 65, 198, 1);
// //   static const Color failedcolor = Color.fromRGBO(177, 2, 2, 0.851);
// //   static const Color successcolor = Color.fromRGBO(3, 117, 3, 0.851);

// // }

// import 'package:flutter/material.dart';

// class AppColors {
//   // 🔒 Fixed Colors (same in both light & dark themes)
//   static const Color buttonColor = Color.fromRGBO(105, 65, 198, 1);
//   static const Color buttonTextColor = Colors.white;
//   static const Color graphcolor = Color.fromRGBO(151, 143, 237, 1);
//   static const Color menudrawer = Color.fromRGBO(105, 65, 198, 1);
//   static const Color bordercolor = Color.fromRGBO(105, 65, 198, 1);
//   static const Color failedcolor = Color.fromRGBO(177, 2, 2, 0.851);
//   static const Color successcolor = Color.fromRGBO(3, 117, 3, 0.851);
  
//   // 🎯 Dynamic Theme-Aware Colors

//   /// Text color according to theme (black in light, white in dark)
//   static Color mainFontColor(BuildContext context) =>
//       Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

//   /// Placeholder or hint color
//   static Color placeholderColor(BuildContext context) =>
//       Theme.of(context).hintColor;

//   /// Text field / card background color
//   static Color fieldcolor(BuildContext context) =>
//       Theme.of(context).inputDecorationTheme.fillColor ??
//       (Theme.of(context).brightness == Brightness.dark
//           ? const Color(0xFF1E1E1E)
//           : const Color(0xFFF5F7F9));

//   /// Divider/line color
//   static Color linecolor(BuildContext context) =>
//       Theme.of(context).dividerColor;
// }



import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color scaffoldLight = Color.fromRGBO(245, 247, 249, 1);
  static const Color hintLight = Color.fromRGBO(170, 170, 170, 1);
  static const Color dividerLight = Colors.grey;
  static const Color fieldLight = Color.fromRGBO(245, 247, 249, 1);
  static const Color cardLight = Colors.white;
  static const Color buttonLight = Color.fromRGBO(105, 65, 198, 1);
  static const Color buttonTextLight = Colors.white;
  static const Color successLight = Color.fromRGBO(3, 117, 3, 0.851);
  static const Color errorLight = Color.fromRGBO(177, 2, 2, 0.851);

  // Dark Theme
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color hintDark = Color.fromRGBO(170, 170, 170, 1);
  static const Color dividerDark = Color(0xFF2C2C2C);
  static const Color fieldDark = Color.fromRGBO(30, 30, 30, 1);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color buttonDark = Color.fromRGBO(105, 65, 198, 1);
  static const Color buttonTextDark = Colors.white;
  static const Color successDark = Color.fromRGBO(3, 117, 3, 0.851);
  static const Color errorDark = Color.fromRGBO(177, 2, 2, 0.851);
}
