import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/controller/asset_controller.dart';
import 'package:wealth_app/presentation/Authentication/controller/auth_controller.dart';
import 'package:wealth_app/presentation/Consent/consent_screen.dart';
import 'package:wealth_app/presentation/Dashboard/controller/dashboard_controller.dart';
import 'package:wealth_app/presentation/Dashboard/screen/controller/filter_controller.dart';
import 'package:wealth_app/presentation/Expense/controller/expense_controller.dart';
import 'package:wealth_app/presentation/Income/controller/income_controller.dart';
import 'package:wealth_app/presentation/Network/network_controller.dart';
import 'package:wealth_app/presentation/Profile/profile_image_controller.dart';
import 'package:wealth_app/utils/Theme/app_theme.dart';
import 'package:wealth_app/utils/Theme/theme_controller.dart';
import 'package:wealth_app/routes/app_routes.dart';

String currentFlavor = 'prod';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(FilterController());
  Get.put(NetworkManager(), permanent: true);
  Get.put(IncomeController());
  Get.put(ExpenseController(), permanent: true);
  Get.put(AssetController());
  Get.put(DashboardController());
  Get.put(ProfileImageController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Obx(
        () => GetMaterialApp(
          // defaultTransition: Transition.fade,
          // transitionDuration: const Duration(milliseconds: 100),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
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
