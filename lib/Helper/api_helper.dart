import 'package:wealth_app/main.dart';

class ApiHelper {
  static String get baseUrl {
    return currentFlavor == 'prod'
    ? 'https://dynamicsmonk-api.azure-api.net/wealthdev'
        : 'https://192.168.1.24:7173/api';
  }



  static String  subscriptionKey =  '507f2afb55654b58b949017a7d8c5f22';
  

  // Asset endpoints
  static String getAssets(String userId) => '$baseUrl/investments/recent/$userId';
  static String addAsset() => '$baseUrl/investments';
  static String deleteAsset(String id) => '$baseUrl/investments/$id';

  // Expense endpoints
  static String getExpenses(String userId) => '$baseUrl/expense/user/$userId';
  static String addExpense() => '$baseUrl/expense';
  static String updateExpense(String id) => '$baseUrl/expense/$id';
  static String deleteExpense(String id) => '$baseUrl/expense/$id';

  // Income endpoints
  static String getIncomes(String userId) => '$baseUrl/incomes/recent/$userId';
  static String addIncome() => '$baseUrl/income';
  static String updateIncome(String id) => '$baseUrl/income/$id';
  static String deleteIncome(String id) => '$baseUrl/income/$id';

  // Users / Auth
  static String addUser() => '$baseUrl/users';
}
