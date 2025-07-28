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

  Widget buildMenuTile({
    required String title,
    required String route,
    required bool isDarkMode,
    double fontSize = 16,
    required BuildContext context,
  }) {
    final String currentRoute = Get.currentRoute;
    final bool isActive = currentRoute == route;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isActive ? AppTextStyle.bold : FontWeight.normal,
          color:
              isActive
                  ? context.buttonColor
                  : (isDarkMode ? context.mainFontColor : context.buttonColor),
        ),
      ),
      onTap: () {
        Get.back();
        if (!isActive) {
          Get.toNamed(route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = Get.currentRoute;
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
                    // Dashboard
                    ListTile(
                      leading: svgIcon(
                        'assets/icons/dashboard.svg',
                        color:
                            isDarkMode
                                ? context.mainFontColor
                                : context.buttonColor,
                      ),
                      title: Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              currentRoute == '/dashboard'
                                  ? AppTextStyle.bold
                                  : AppTextStyle.mediumWeight,
                          color:
                              currentRoute == '/dashboard'
                                  ? context.buttonColor
                                  : context.mainFontColor,
                        ),
                      ),
                      onTap: () {
                        Get.back();
                        if (currentRoute != '/dashboard') {
                          Get.toNamed('/dashboard');
                        }
                      },
                    ),

                    // Income
                    ExpansionTile(
                      leading: svgIcon(
                        'assets/icons/income.svg',
                        color:
                            isDarkMode
                                ? context.mainFontColor
                                : context.buttonColor,
                      ),
                      title: Text(
                        "Manage Income",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                          color: context.mainFontColor,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          context: context,
                          title: "My Income",
                          route: '/income',
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),

                    // Expenses
                    ExpansionTile(
                      leading: svgIcon(
                        'assets/icons/expenses.svg',
                        color:
                            isDarkMode
                                ? context.mainFontColor
                                : context.buttonColor,
                      ),
                      title: Text(
                        "Manage Expenses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                          color: context.mainFontColor,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          context: context,
                          title: "My Expenses",
                          route: '/expenses',
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),

                    // Assets
                    ExpansionTile(
                      leading: svgIcon(
                        'assets/icons/assets.svg',
                        color:
                            isDarkMode
                                ? context.mainFontColor
                                : context.buttonColor,
                      ),
                      title: Text(
                        "Manage Assets/Investments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                          color: context.mainFontColor,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          context: context,
                          title: "My Assets & Investment",
                          route: '/assets',
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),

                    // Upload Document
                    ExpansionTile(
                      leading: svgIcon(
                        'assets/icons/document_icon.svg',
                        color:
                            isDarkMode
                                ? context.mainFontColor
                                : context.buttonColor,
                      ),
                      title: Text(
                        "Upload Document",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                          color: context.mainFontColor,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          context: context,
                          title: "Upload Document",
                          route: '/upload',
                          isDarkMode: isDarkMode,
                        ),
                      ],
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
