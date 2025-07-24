import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/text_styles.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  Widget svgIcon(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      height: 22,
      width: 22,
      fit: BoxFit.contain,
      placeholderBuilder: (_) =>
          const Icon(Icons.image_not_supported, size: 22),
    );
  }

  Widget buildMenuTile({
    required String title,
    required String route,
    double fontSize = 16,
  }) {
    final String currentRoute = Get.currentRoute;
    final bool isActive = currentRoute == route;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isActive ? AppTextStyle.bold : FontWeight.normal,
          color: isActive ? AppColors.buttonColor : AppColors.menudrawer,
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

    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F5F7), Color(0xFFEDEDED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: AppTextStyle.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
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
                      leading: svgIcon('assets/icons/dashboard.svg'),
                      title: Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: currentRoute == '/dashboard'
                              ? AppTextStyle.bold
                              : AppTextStyle.mediumWeight,
                          color: currentRoute == '/dashboard'
                              ? AppColors.buttonColor
                              : Colors.black,
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
                      leading: svgIcon('assets/icons/income.svg'),
                      title: const Text(
                        "Manage Income",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          title: "My Income",
                          route: '/income',
                        ),
                      ],
                    ),

                    // Expenses
                    ExpansionTile(
                      leading: svgIcon('assets/icons/expenses.svg'),
                      title: const Text(
                        "Manage Expenses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          title: "My Expenses",
                          route: '/expenses',
                        ),
                      ],
                    ),

                    // Assets
                    ExpansionTile(
                      leading: svgIcon('assets/icons/assets.svg'),
                      title: const Text(
                        "Manage Assest/Investments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          title: "My Assets & Investment",
                          route: '/assets',
                        ),
                      ],
                    ),
                     ExpansionTile(
                      leading: SvgPicture.asset('assets/icons/document_icon.svg',color: AppColors.bordercolor,height: 25, width: 25,),
                      title: const Text(
                        "Upload Document",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: AppTextStyle.mediumWeight,
                        ),
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.10,
                      ),
                      children: [
                        buildMenuTile(
                          title: "Upload Document",
                          route: '/upload',
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
