import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/screens/mainscreens/profile_screen.dart';
import 'package:wealth_app/screens/subscreens/notification_screen.dart';
import 'package:wealth_app/controllers/profile_image_controller.dart';

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
        Container(
          height: iconSize,
          width: 1,
          color: context.lineColor,
          margin: EdgeInsets.symmetric(horizontal: width * 0.02),
        ),
        Obx(() {
          final path = controller.imagePath.value;
          final profileImageFile = (path != null) ? File(path) : null;

          return Padding(
            padding: EdgeInsets.only(right: paddingRight),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                controller.loadImagePath();
              },
              child: CircleAvatar(
                radius: iconSize * 0.7,
                backgroundImage:
                    (profileImageFile != null && profileImageFile.existsSync())
                        ? FileImage(profileImageFile)
                        : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
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
