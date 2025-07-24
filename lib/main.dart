import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wealth_app/controllers/asset_controller.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';
import 'package:wealth_app/controllers/expense_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/profile_image_controller.dart';
import 'package:wealth_app/screens/Authentication/login_screen.dart';
import 'package:wealth_app/screens/mainscreens/dashboard_screen.dart';
import 'package:wealth_app/screens/mainscreens/income_overview.dart';
import 'package:wealth_app/screens/mainscreens/my_asset_investment_screen.dart';
import 'package:wealth_app/screens/mainscreens/my_expenses_screen.dart';
import 'package:wealth_app/screens/mainscreens/profile_screen.dart';
import 'package:wealth_app/screens/mainscreens/splash_screen.dart';
import 'package:wealth_app/screens/subscreens/consent_screen.dart';
import 'package:wealth_app/screens/subscreens/upload_document_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: '/consent',
        // initialRoute: '/splash',
        getPages: [
          GetPage(name: '/dashboard', page: () => DashboardScreen()),
          GetPage(name: '/profile', page: () => const ProfileScreen()),
          GetPage(name: '/income', page: () => const IncomeOverviewScreen()),
          GetPage(name: '/expenses', page: () => const MyExpensesScreen()),
          GetPage(name: '/assets', page: () => const MyAssetsAndInvestmentsScreen()),
          GetPage(name: '/consent', page: () => const ConsentGatekeeper()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/upload', page: () => const UploadDocumentScreen()),
          GetPage(name: '/splash', page: () => const SplashScreen()),

        ],
        // home: const HomeWithMenu(),
      ),
    );
  }
}

class HomeWithMenu extends StatelessWidget {
  const HomeWithMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ConsentGatekeeper(),
    );
  }
}
