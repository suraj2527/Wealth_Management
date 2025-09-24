import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/utils/Theme/theme_extension.dart';
import 'package:wealth_app/presentation/Other/notification_screen.dart';
import 'package:wealth_app/presentation/Profile/profile_image_controller.dart';
import 'package:wealth_app/presentation/Profile/profile_screen.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniversalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;
    final paddingRight = width * 0.03;
    final iconSize = width * 0.06;

    final ProfileImageController controller = Get.find();

    return AppBar(
      backgroundColor: context.backgroundColor,
      surfaceTintColor: context.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: SvgPicture.asset(
                'assets/icons/menu_icon.svg',
                height: iconSize * 0.8,
                width: iconSize * 0.8,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? context.mainFontColor : context.mainFontColor,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/search_icon.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              isDarkMode ? context.mainFontColor : context.buttonColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/notification_icon.svg',
            height: iconSize * 1.1,
            width: iconSize * 1.1,
            colorFilter: ColorFilter.mode(
              isDarkMode ? context.mainFontColor : context.buttonColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => showNotificationDialog(context),
        ),
        // Container(
        //   height: iconSize,
        //   width: 1,
        //   color: context.buttonColor,
        //   margin: EdgeInsets.symmetric(horizontal: width * 0.02),
        // ),
        Obx(() {
          final path = controller.imagePath.value;
          final profileImageFile = (path != null) ? File(path) : null;
          final bool hasValidImage =
              profileImageFile != null && profileImageFile.existsSync();

          return Padding(
            padding: EdgeInsets.only(right: paddingRight),
            child: GestureDetector(
              onTap: () async {
                final currentRoute = ModalRoute.of(context)?.settings.name;

                if (currentRoute != '/profile') {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/profile'),
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  controller.loadImagePath();
                }
              },

              child: Container(
                width: iconSize * 1.4,
                height: iconSize * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.buttonColor, width: 1),
                  color: context.fieldColor,
                  image:
                      hasValidImage
                          ? DecorationImage(
                            image: FileImage(profileImageFile),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    !hasValidImage
                        ? Icon(
                          Icons.person,
                          size: iconSize * 0.8,
                          color: context.placeholderColor,
                        )
                        : null,
              ),
            ),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: context.lineColor),
      ),
    );
  }
}
