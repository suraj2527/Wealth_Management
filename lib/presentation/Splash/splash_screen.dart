import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/controller/asset_controller.dart';
import 'package:wealth_app/presentation/Authentication/controller/auth_controller.dart';
import 'package:wealth_app/presentation/Authentication/screen/login_screen.dart';
import 'package:wealth_app/presentation/Dashboard/controller/dashboard_controller.dart';
import 'package:wealth_app/presentation/Dashboard/screen/dashboard_screen.dart';
import 'package:wealth_app/presentation/Expense/controller/expense_controller.dart';
import 'package:wealth_app/presentation/Income/controller/income_controller.dart';
import 'package:wealth_app/utils/constants/text_styles.dart';
import 'package:wealth_app/widgets/dot_loader.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  final IncomeController incomeController = Get.put(IncomeController());
  final ExpenseController expenseController = Get.put(ExpenseController());
  final AssetController assetController = Get.put(AssetController());

  final String fullText = 'Wealth Management';
  String animatedText = '';
  int charIndex = 0;
  bool textFadeIn = false;

  late AnimationController _logoController;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _setupLogoFade();
    _startTextAnimation();
    checkLoginStatus();
  }

  void _setupLogoFade() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _logoController.forward();
  }

  void _startTextAnimation() async {
    while (charIndex < fullText.length) {
      await Future.delayed(const Duration(milliseconds: 70));
      setState(() {
        animatedText += fullText[charIndex];
        charIndex++;
      });
    }

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      textFadeIn = true;
    });
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    bool success = await authController.trySilentLogin();

    if (success) {
      final userId = authController.dbUserId.value;

      await dashboardController.initializeDashboard(userId, force: true);

      Get.offAll(() => const DashboardScreen());
    } else {
      // Get.offAll(() => const DashboardScreen() );

      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoOpacity,
              child: SvgPicture.asset(
                'assets/images/main_logo.svg',
                height: 60,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              opacity: textFadeIn ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    animatedText,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: AppTextStyle.bold,
                      color: context.mainFontColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const DotLoader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
