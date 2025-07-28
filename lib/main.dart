import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/controllers/asset_controller.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';
import 'package:wealth_app/controllers/expense_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/profile_image_controller.dart';
import 'package:wealth_app/controllers/theme_controller.dart';
import 'package:wealth_app/routes/app_routes.dart';
import 'package:wealth_app/screens/subscreens/consent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(DashboardController());
  Get.put(ProfileImageController());
  Get.put(IncomeController());
  Get.put(ExpenseController());
  Get.put(AssetController());
  Get.put(FilterController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Obx(
        () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Roboto',
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.scaffoldLight,
            hintColor: AppColors.hintLight,
            dividerColor: AppColors.dividerLight,
            inputDecorationTheme: InputDecorationTheme(
              fillColor: AppColors.fieldLight,
            ),
            cardColor: AppColors.cardLight,
            colorScheme: ColorScheme.light(
              primary: AppColors.buttonLight,
              onPrimary: AppColors.buttonTextLight,
              secondaryContainer: AppColors.successLight,
              error: AppColors.errorLight,
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'Roboto',
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.scaffoldDark,
            hintColor: AppColors.hintDark,
            dividerColor: AppColors.dividerDark,
            inputDecorationTheme: InputDecorationTheme(
              fillColor: AppColors.fieldDark,
            ),
            cardColor: AppColors.cardDark,
            colorScheme: ColorScheme.dark(
              primary: AppColors.buttonDark,
              onPrimary: AppColors.buttonTextDark,
              secondaryContainer: AppColors.successDark,
              error: AppColors.errorDark,
            ),
          ),
          themeMode: themeController.themeMode.value,
          initialRoute: '/consent',
          getPages: AppRoutes.routes,
        ),
      ),
    );
  }
}

class HomeWithMenu extends StatelessWidget {
  const HomeWithMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ConsentGatekeeper());
  }
}
