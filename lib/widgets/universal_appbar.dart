// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:provider/provider.dart';
// import 'package:wealth_app/screens/mainscreens/profile_screen.dart';
// import 'package:wealth_app/screens/subscreens/notification_screen.dart';
// import 'package:wealth_app/controllers/profile_image_controller.dart'; // Make sure this is the correct import

// class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const UniversalAppBar({super.key});

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final paddingRight = width * 0.03;
//     final iconSize = width * 0.06;

//     final profileImagePath = context.watch<ProfileImageProvider>().imagePath;
//     final profileImageFile = profileImagePath != null ? File(profileImagePath) : null;

//     return AppBar(
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       leading: Builder(
//         builder: (context) => IconButton(
//           icon: SvgPicture.asset(
//             'assets/icons/menu_icon.svg',
//             height: iconSize * 0.8,
//             width: iconSize * 0.8,
//             colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
//           ),
//           onPressed: () => Scaffold.of(context).openDrawer(),
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: SvgPicture.asset(
//             'assets/icons/search_icon.svg',
//             width: iconSize,
//             height: iconSize,
//           ),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: SvgPicture.asset(
//             'assets/icons/notification_icon.svg',
//             height: iconSize * 1.1,
//             width: iconSize * 1.1,
//           ),
//           onPressed: () => showNotificationDialog(context),
//         ),
//         Container(
//           height: iconSize,
//           width: 1,
//           color: const Color.fromARGB(255, 114, 114, 114),
//           margin: EdgeInsets.symmetric(horizontal: width * 0.02),
//         ),
//         Padding(
//           padding: EdgeInsets.only(right: paddingRight),
//           child: GestureDetector(
//             onTap: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfileScreen()),
//               );
//               // ProfileImageProvider will notify listeners automatically
//             },
//             child: CircleAvatar(
//               radius: iconSize * 0.7,
//               backgroundImage: (profileImageFile != null && profileImageFile.existsSync())
//                   ? FileImage(profileImageFile)
//                   : const AssetImage("assets/images/profile.png") as ImageProvider,
//             ),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(
//           height: 1,
//           color: const Color.fromARGB(255, 114, 114, 114),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/screens/mainscreens/profile_screen.dart';
import 'package:wealth_app/screens/subscreens/notification_screen.dart';
import 'package:wealth_app/controllers/profile_image_controller.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniversalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingRight = width * 0.03;
    final iconSize = width * 0.06;

    // Access controller instance
    final ProfileImageController controller = Get.find();

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: SvgPicture.asset(
            'assets/icons/menu_icon.svg',
            height: iconSize * 0.8,
            width: iconSize * 0.8,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
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
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/notification_icon.svg',
            height: iconSize * 1.1,
            width: iconSize * 1.1,
          ),
          onPressed: () => showNotificationDialog(context),
        ),
        Container(
          height: iconSize,
          width: 1,
          color: const Color.fromARGB(255, 114, 114, 114),
          margin: EdgeInsets.symmetric(horizontal: width * 0.02),
        ),

        /// ✅ Reactively listen to profile image changes
        Obx(() {
          final path = controller.imagePath.value;
          final profileImageFile = (path != null) ? File(path) : null;

          return Padding(
            padding: EdgeInsets.only(right: paddingRight),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                controller.loadImagePath(); // Reload from SharedPreferences if needed
              },
              child: CircleAvatar(
                radius: iconSize * 0.7,
                backgroundImage: (profileImageFile != null && profileImageFile.existsSync())
                    ? FileImage(profileImageFile)
                    : const AssetImage("assets/images/profile.png") as ImageProvider,
              ),
            ),
          );
        }),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color.fromARGB(255, 114, 114, 114),
        ),
      ),
    );
  }
}
