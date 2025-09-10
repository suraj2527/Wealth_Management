import 'package:get/get.dart';
import 'package:wealth_app/presentation/screens/Authentication/login_screen.dart';
import 'package:wealth_app/presentation/screens/mainscreens/dashboard_screen.dart';
import 'package:wealth_app/presentation/screens/mainscreens/income_overview.dart';
import 'package:wealth_app/presentation/screens/mainscreens/my_asset_investment_screen.dart';
import 'package:wealth_app/presentation/screens/mainscreens/my_expenses_screen.dart';
import 'package:wealth_app/presentation/screens/mainscreens/profile_screen.dart';
import 'package:wealth_app/presentation/screens/mainscreens/splash_screen.dart';
import 'package:wealth_app/presentation/screens/subscreens/consent_screen.dart';
import 'package:wealth_app/presentation/screens/subscreens/upload_document_screen.dart';
import 'package:wealth_app/willGenerator/will_generator.dart';

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
    GetPage(name: '/will', page: () => const WillGeneratorPage()),
  ];
  
}
