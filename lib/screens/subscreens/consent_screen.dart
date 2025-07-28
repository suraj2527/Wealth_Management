import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/screens/mainscreens/splash_screen.dart';
import 'package:wealth_app/widgets/consent_dialog.dart';
import 'package:wealth_app/widgets/dot_loader.dart';

class ConsentGatekeeper extends StatefulWidget {
  const ConsentGatekeeper({super.key});

  @override
  State<ConsentGatekeeper> createState() => _ConsentGatekeeperState();
}

class _ConsentGatekeeperState extends State<ConsentGatekeeper> {
  @override
  void initState() {
    super.initState();
    _checkConsentStatus();
  }

  Future<void> _checkConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final consentGiven = prefs.getBool('consent_accepted') ?? false;

    if (consentGiven) {
      _navigateToLogin();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showConsent1());
    }
  }

  void _navigateToLogin() {
    Get.offAll(() => const SplashScreen());
  }

  Future<void> _showConsent1() async {
    await Get.dialog(
      ConsentDialog(
        title: 'Consent Statement',
        content:
            'I hereby voluntarily agree to participate in the [Family Wealth Management]... (full text)',
        agreeText: 'I consent',
        disagreeText: 'I do not consent',
        onAgree: () {
          Get.back();
          _showConsent2();
        },
        onDisagree: () => _exitApp(),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showConsent2() async {
    await Get.dialog(
      ConsentDialog(
        title: 'Fetch Your Gmail Instantly',
        content:
            'I hereby voluntarily agree to participate in the [insert name of project, program, activity, or research]... (full text)',
        agreeText: 'I agree',
        disagreeText: 'I disagree',
        onAgree: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('consent_accepted', true);
          Get.back();
          _navigateToLogin();
        },
        onDisagree: () => _exitApp(),
      ),
      barrierDismissible: false,
    );
  }

  void _exitApp() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Consent Required',
          style: TextStyle(fontWeight: AppTextStyle.mediumWeight),
        ),
        content: const Text('You must accept both consents to proceed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyle(color: context.buttonColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Exit App',
          style: TextStyle(fontWeight: AppTextStyle.mediumWeight),
        ),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.mainFontColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Exit',
              style: TextStyle(color: context.buttonColor),
            ),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) {
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _confirmExitDialog();
        }
      },
      child: const Scaffold(
        body: Center(child: DotLoader()),
      ),
    );
  }
}
