import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/screens/mainscreens/hello_screen.dart';
import 'package:wealth_app/widgets/custom_button.dart';
import 'package:wealth_app/widgets/dot_loader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool _isLoading = false;

  Future<bool> _onExitPressed() async {
    bool shouldExit = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.fieldColor,
        title: Text(
          "Exit App",
          style: TextStyle(fontWeight: AppTextStyle.mediumWeight),
        ),
        content: const Text("Do you really want to exit?"),
        actions: [
          TextButton(
            onPressed: () {
              shouldExit = false;
              Navigator.of(context).pop();
            },
            child: Text("No", style: TextStyle(color: context.mainFontColor)), 
          ),
          TextButton(
            onPressed: () {
              shouldExit = true;
              Navigator.of(context).pop();
            },
            child: Text("Exit", style: TextStyle(color: context.theme.colorScheme.primary)),
          ),
        ],
      ),
    );
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final exit = await _onExitPressed();
          if (exit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/main_logo.svg',
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: context.mainFontColor, 
                        ),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: CustomButton(
                          text: "Login",
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await authController.login();
                                    if (authController.isLoggedIn.value) {
                                      Get.off(() => const HelloScreen());
                                    } else {
                                      Get.snackbar(
                                        "Login Failed",
                                        "Please try again.",
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      "Login Cancelled",
                                      "Please try again.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      // ignore: use_build_context_synchronously
                                      colorText: context.mainFontColor, 
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4), 
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DotLoader(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
