// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:wealth_app/constants/text_styles.dart';
// import 'package:wealth_app/extension/theme_extension.dart';

// class SideMenuDrawer extends StatelessWidget {
//   const SideMenuDrawer({super.key});

//   Widget svgIcon(String assetPath, {Color? color}) {
//     return SvgPicture.asset(
//       assetPath,
//       height: 22,
//       width: 22,
//       fit: BoxFit.contain,
//       colorFilter:
//           color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
//       placeholderBuilder:
//           (_) => const Icon(Icons.image_not_supported, size: 22),
//     );
//   }

//   void navigateWithTransition(String route) {
//     Get.back();
//     Future.delayed(const Duration(milliseconds: 300), () {
//       Get.toNamed(route);
//     });
//   }

//   Widget buildMenuTile({
//     required String title,
//     required String route,
//     required String iconPath,
//     required BuildContext context,
//     required bool isDarkMode,
//   }) {
//     final String currentRoute = Get.currentRoute;
//     final bool isActive = currentRoute == route;

//     return ListTile(
//       leading: svgIcon(
//         iconPath,
//         color: isDarkMode ? context.mainFontColor : context.buttonColor,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: isActive ? AppTextStyle.bold : AppTextStyle.mediumWeight,
//           color: isActive ? context.buttonColor : context.mainFontColor,
//         ),
//       ),
//       onTap: () {
//         if (!isActive) {
//           navigateWithTransition(route);
//         } else {
//           Get.back();
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Drawer(
//       width: 280,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topRight: Radius.circular(32),
//           bottomRight: Radius.circular(32),
//         ),
//       ),
//       child: Container(
//         color: context.backgroundColor,
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 20,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Menu",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: AppTextStyle.bold,
//                         color: context.mainFontColor,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, color: context.mainFontColor),
//                       onPressed: () => Get.back(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Menu Items
//               Expanded(
//                 child: ListView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   children: [
//                     buildMenuTile(
//                       context: context,
//                       title: "Dashboard",
//                       route: '/dashboard',
//                       iconPath: 'assets/icons/dashboard.svg',
//                       isDarkMode: isDarkMode,
//                     ),
//                     buildMenuTile(
//                       context: context,
//                       title: "My Income",
//                       route: '/income',
//                       iconPath: 'assets/icons/income.svg',
//                       isDarkMode: isDarkMode,
//                     ),
//                     buildMenuTile(
//                       context: context,
//                       title: "My Expenses",
//                       route: '/expenses',
//                       iconPath: 'assets/icons/expenses.svg',
//                       isDarkMode: isDarkMode,
//                     ),
//                     buildMenuTile(
//                       context: context,
//                       title: "My Assets & Investments",
//                       route: '/assets',
//                       iconPath: 'assets/icons/assets.svg',
//                       isDarkMode: isDarkMode,
//                     ),
//                     // buildMenuTile(
//                     //   context: context,
//                     //   title: "Upload Document",
//                     //   route: '/upload',
//                     //   iconPath: 'assets/icons/document_icon.svg',
//                     //   isDarkMode: isDarkMode,
//                     // ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  Widget svgIcon(String assetPath, {Color? color}) {
    return SvgPicture.asset(
      assetPath,
      height: 22,
      width: 22,
      fit: BoxFit.contain,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      placeholderBuilder:
          (_) => const Icon(Icons.image_not_supported, size: 22),
    );
  }

  void navigateWithTransition(String route) {
    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.toNamed(route);
    });
  }

  Widget buildMenuTile({
    required String title,
    required String route,
    required String iconPath,
    required BuildContext context,
    required bool isDarkMode,
  }) {
    // ✅ Default route set to dashboard if current route is empty or "/"
    String currentRoute = Get.currentRoute.isEmpty || Get.currentRoute == "/"
        ? "/dashboard"
        : Get.currentRoute;

    final bool isActive = currentRoute == route;

    return ListTile(
      leading: svgIcon(
        iconPath,
        color: isDarkMode ? context.mainFontColor : context.buttonColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isActive ? AppTextStyle.bold : AppTextStyle.mediumWeight,
          color: isActive ? context.buttonColor : context.mainFontColor,
        ),
      ),
      onTap: () {
        if (!isActive) {
          navigateWithTransition(route);
        } else {
          Get.back();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Container(
        color: context.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: AppTextStyle.bold,
                        color: context.mainFontColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.mainFontColor),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    buildMenuTile(
                      context: context,
                      title: "Dashboard",
                      route: '/dashboard',
                      iconPath: 'assets/icons/dashboard.svg',
                      isDarkMode: isDarkMode,
                    ),
                    buildMenuTile(
                      context: context,
                      title: "My Income",
                      route: '/income',
                      iconPath: 'assets/icons/income.svg',
                      isDarkMode: isDarkMode,
                    ),
                    buildMenuTile(
                      context: context,
                      title: "My Expenses",
                      route: '/expenses',
                      iconPath: 'assets/icons/expenses.svg',
                      isDarkMode: isDarkMode,
                    ),
                    buildMenuTile(
                      context: context,
                      title: "My Assets & Investments",
                      route: '/assets',
                      iconPath: 'assets/icons/assets.svg',
                      isDarkMode: isDarkMode,
                    ),
                    // buildMenuTile(
                    //   context: context,
                    //   title: "Upload Document",
                    //   route: '/upload',
                    //   iconPath: 'assets/icons/document_icon.svg',
                    //   isDarkMode: isDarkMode,
                    // ),

                     buildMenuTile(
                      context: context,
                      title: "Will Management",
                      route: '/will',
                      iconPath: 'assets/icons/assets.svg',
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
