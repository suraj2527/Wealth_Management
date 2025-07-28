import 'package:get/get.dart';
import 'package:wealth_app/screens/Authentication/login_screen.dart';
import 'package:wealth_app/screens/mainscreens/dashboard_screen.dart';
import 'package:wealth_app/screens/mainscreens/income_overview.dart';
import 'package:wealth_app/screens/mainscreens/my_asset_investment_screen.dart';
import 'package:wealth_app/screens/mainscreens/my_expenses_screen.dart';
import 'package:wealth_app/screens/mainscreens/profile_screen.dart';
import 'package:wealth_app/screens/mainscreens/splash_screen.dart';
import 'package:wealth_app/screens/subscreens/consent_screen.dart';
import 'package:wealth_app/screens/subscreens/upload_document_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/dashboard', page: () => DashboardScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/income', page: () => const IncomeOverviewScreen()),
    GetPage(name: '/expenses', page: () => const MyExpensesScreen()),
    GetPage(name: '/assets', page: () => const MyAssetsAndInvestmentsScreen()),
    GetPage(name: '/consent', page: () => const ConsentGatekeeper()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/upload', page: () => const UploadDocumentScreen()),
    GetPage(name: '/splash', page: () => const SplashScreen()),
  ];
}
