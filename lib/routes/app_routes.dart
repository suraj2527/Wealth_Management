import 'package:get/get.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/screen/my_asset_investment_screen.dart';
import 'package:wealth_app/presentation/Authentication/screen/login_screen.dart';
import 'package:wealth_app/presentation/Consent/consent_screen.dart';
import 'package:wealth_app/presentation/Dashboard/screen/dashboard_screen.dart';
import 'package:wealth_app/presentation/Expense/screen/my_expenses_screen.dart';
import 'package:wealth_app/presentation/Income/screen/income_overview.dart';
import 'package:wealth_app/presentation/Profile/profile_screen.dart';
import 'package:wealth_app/presentation/Splash/splash_screen.dart';
import 'package:wealth_app/presentation/Upload%20Document/screen/upload_document_screen.dart';
import 'package:wealth_app/presentation/willGenerator/will_generator.dart';

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
