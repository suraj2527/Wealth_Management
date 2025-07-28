import 'package:get/get.dart';
import 'package:wealth_app/models/expense_model.dart';
import 'package:wealth_app/models/income_model.dart';
import 'package:wealth_app/models/asset_model.dart';

enum FilterType { recentlyAdded, lastMonth, lastYear }

class FilterController extends GetxController {
  // Income
  var incomeFilterType = FilterType.recentlyAdded.obs;
  var originalIncomeList = <IncomeModel>[].obs;
  var filteredIncomeList = <IncomeModel>[].obs;

  // Expense
  var expenseFilterType = FilterType.recentlyAdded.obs;
  var originalExpenseList = <ExpenseModel>[].obs;
  var filteredExpenseList = <ExpenseModel>[].obs;

  // Asset
  var assetFilterType = FilterType.recentlyAdded.obs;
  var originalAssetList = <AssetModel>[].obs;
  var filteredAssetList = <AssetModel>[].obs;

  // ---------------- INCOME ---------------- //
  void setIncomeData(List<IncomeModel> incomes) {
    originalIncomeList.assignAll(incomes);
    applyIncomeFilter();
  }

  void updateIncomeFilter(FilterType type) {
    incomeFilterType.value = type;
    applyIncomeFilter();
  }

  void applyIncomeFilter() {
    final filter = incomeFilterType.value;
    final now = DateTime.now();

    List<IncomeModel> sortedList =
        originalIncomeList.where((income) {
          final date = DateTime.tryParse(income.date);
          if (date == null) return false;

          switch (filter) {
            case FilterType.lastMonth:
              final lastMonth = DateTime(now.year, now.month - 1);
              return date.year == lastMonth.year &&
                  date.month == lastMonth.month;
            case FilterType.lastYear:
              return date.year == now.year - 1;
            case FilterType.recentlyAdded:
              return true;
          }
        }).toList();

    sortedList.sort(
      (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
    );
    filteredIncomeList.assignAll(sortedList);
  }

  // ---------------- EXPENSE ---------------- //
  void setExpenseData(List<ExpenseModel> expenses) {
    originalExpenseList.assignAll(expenses);
    applyExpenseFilter();
  }

  void updateExpenseFilter(FilterType type) {
    expenseFilterType.value = type;
    applyExpenseFilter();
  }

  void applyExpenseFilter() {
    final filter = expenseFilterType.value;
    final now = DateTime.now();

    List<ExpenseModel> sortedList =
        originalExpenseList.where((expense) {
          final date = DateTime.tryParse(expense.date);
          if (date == null) return false;

          switch (filter) {
            case FilterType.lastMonth:
              final lastMonth = DateTime(now.year, now.month - 1);
              return date.year == lastMonth.year &&
                  date.month == lastMonth.month;
            case FilterType.lastYear:
              return date.year == now.year - 1;
            case FilterType.recentlyAdded:
              return true;
          }
        }).toList();

    sortedList.sort(
      (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)),
    );
    filteredExpenseList.assignAll(sortedList);
  }

  // ---------------- ASSET ---------------- //
  void setAssetData(List<AssetModel> assets) {
    originalAssetList.assignAll(assets);
    applyAssetFilter();
  }

  void updateAssetFilter(FilterType type) {
    assetFilterType.value = type;
    applyAssetFilter();
  }

  void applyAssetFilter() {
    final filter = assetFilterType.value;
    final now = DateTime.now();

    List<AssetModel> sortedList =
        originalAssetList.where((asset) {
          final startDate = DateTime.tryParse(asset.startDate);
          if (startDate == null) return false;

          switch (filter) {
            case FilterType.lastMonth:
              final lastMonth = DateTime(now.year, now.month - 1);
              return startDate.year == lastMonth.year &&
                  startDate.month == lastMonth.month;
            case FilterType.lastYear:
              return startDate.year == now.year - 1;
            case FilterType.recentlyAdded:
              return true;
          }
        }).toList();

    sortedList.sort((a, b) {
      final aDate = DateTime.tryParse(a.startDate);
      final bDate = DateTime.tryParse(b.startDate);
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });

    filteredAssetList.assignAll(sortedList);
  }

  // Dropdown
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
