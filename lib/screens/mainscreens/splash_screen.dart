import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/screens/Authentication/login_screen.dart';
import 'package:wealth_app/screens/mainscreens/dashboard_screen.dart';
import 'package:wealth_app/widgets/dot_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.put(AuthController());
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
    Get.offAll(() => DashboardScreen());
  } else {
    Get.offAll(() => LoginScreen());
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
      backgroundColor: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: AppTextStyle.bold,
                      color: AppColors.mainFontColor,
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
