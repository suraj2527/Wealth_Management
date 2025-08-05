import 'package:get/get.dart';
import 'package:wealth_app/models/expense_model.dart';
import 'package:wealth_app/models/income_model.dart';
import 'package:wealth_app/models/asset_model.dart';

enum FilterType { recentlyAdded, lastMonth, lastYear }

class FilterController extends GetxController {
  // Filters
  var incomeFilterType = FilterType.recentlyAdded.obs;
  var expenseFilterType = FilterType.recentlyAdded.obs;
  var assetFilterType = FilterType.recentlyAdded.obs;

  var selectedYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;

  // Original & Filtered Lists
  var originalIncomeList = <IncomeModel>[].obs;
  var filteredIncomeList = <IncomeModel>[].obs;

  var originalExpenseList = <ExpenseModel>[].obs;
  var filteredExpenseList = <ExpenseModel>[].obs;

  var originalAssetList = <AssetModel>[].obs;
  var filteredAssetList = <AssetModel>[].obs;

  // Totals for Dashboard
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxDouble totalAsset = 0.0.obs;

  // ---------------- INCOME ---------------- //
  void setIncomeData(List<IncomeModel> incomes) {
    originalIncomeList.assignAll(incomes);
    applyIncomeFilter();
    totalIncome.value =
        originalIncomeList.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateIncomeFilter(FilterType type) {
    incomeFilterType.value = type;
    applyIncomeFilter();
  }

  void applyIncomeFilter() {
    // No filtering yet
    filteredIncomeList.assignAll(originalIncomeList);
  }

  // ---------------- EXPENSE ---------------- //
  void setExpenseData(List<ExpenseModel> expenses) {
    originalExpenseList.assignAll(expenses);
    applyExpenseFilter();
    totalExpense.value =
        originalExpenseList.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateExpenseFilter(FilterType type) {
    expenseFilterType.value = type;
    applyExpenseFilter();
  }

  void applyExpenseFilter() {
    filteredExpenseList.assignAll(originalExpenseList);
  }

  // ---------------- ASSET ---------------- //
  void setAssetData(List<AssetModel> assets) {
    originalAssetList.assignAll(assets);
    applyAssetFilter();
    totalAsset.value =
        originalAssetList.fold(0.0, (sum, item) => sum + item.amount);
  }

  void updateAssetFilter(FilterType type) {
    assetFilterType.value = type;
    applyAssetFilter();
  }

  void applyAssetFilter() {
    filteredAssetList.assignAll(originalAssetList);
  }

  String getFilterLabel(FilterType type) {
    switch (type) {
      case FilterType.recentlyAdded:
        return 'Recently Added';
      case FilterType.lastMonth:
        return 'Last Month';
      case FilterType.lastYear:
        return 'Last Year';
    }
  }
}
