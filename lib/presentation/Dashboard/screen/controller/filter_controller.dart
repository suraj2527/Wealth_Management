import 'package:get/get.dart';
import 'package:wealth_app/presentation/Expense/model/expense_model.dart';
import 'package:wealth_app/presentation/Income/model/income_model.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/model/asset_model.dart';

// Enums
enum IncomeFilterType { all, salary, rent, business, capitalGain, other }

enum ExpenseFilterType { all, housing, food, transport, healthcare, other }

enum AssetFilterType { all, mutualFunds, fixedDeposit, gold, other }

class FilterController extends GetxController {
  // Filters
  var selectedIncomeType = IncomeFilterType.all.obs;
  var selectedExpenseType = ExpenseFilterType.all.obs;
  var selectedAssetType = AssetFilterType.all.obs;

  // Data Lists
  var originalIncomeList = <IncomeModel>[].obs;
  var filteredIncomeList = <IncomeModel>[].obs;

  var originalExpenseList = <ExpenseModel>[].obs;
  var filteredExpenseList = <ExpenseModel>[].obs;

  var originalAssetList = <AssetModel>[].obs;
  var filteredAssetList = <AssetModel>[].obs;

  // Totals
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;
  RxDouble totalAsset = 0.0.obs;

  // -------------------- INCOME -------------------- //
  static const Map<IncomeFilterType, String> _incomeMap = {
    IncomeFilterType.salary: 'Salary',
    IncomeFilterType.rent: 'Rent',
    IncomeFilterType.business: 'Business',
    IncomeFilterType.capitalGain: 'Capital Gain',
    IncomeFilterType.other: 'Other',
  };

  void setIncomeData(List<IncomeModel> incomes) {
    originalIncomeList.assignAll(incomes);
    applyIncomeFilter();
    totalIncome.value = filteredIncomeList.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  void updateIncomeFilter(IncomeFilterType type) {
    selectedIncomeType.value = type;
    applyIncomeFilter();
  }

  void applyIncomeFilter() {
    if (selectedIncomeType.value == IncomeFilterType.all) {
      filteredIncomeList.assignAll(originalIncomeList);
    } else if (selectedIncomeType.value == IncomeFilterType.other) {
      final values = _incomeMap.values.toList();
      filteredIncomeList.assignAll(
        originalIncomeList.where(
          (income) => !values.contains(income.incomeType),
        ),
      );
    } else {
      final selectedLabel = _incomeMap[selectedIncomeType.value];
      filteredIncomeList.assignAll(
        originalIncomeList.where(
          (income) => income.incomeType == selectedLabel,
        ),
      );
    }
  }

  String getIncomeFilterLabel(IncomeFilterType type) {
    if (type == IncomeFilterType.all) return 'Show All';
    return _incomeMap[type]!;
  }

  // -------------------- EXPENSE -------------------- //
  static const Map<ExpenseFilterType, String> _expenseMap = {
    ExpenseFilterType.housing: 'Housing',
    ExpenseFilterType.food: 'Food',
    ExpenseFilterType.transport: 'Transport',
    ExpenseFilterType.healthcare: 'Healthcare',
    ExpenseFilterType.other: 'Other',
  };

  void setExpenseData(List<ExpenseModel> expenses) {
    originalExpenseList.assignAll(expenses);
    applyExpenseFilter();
    totalExpense.value = filteredExpenseList.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  void updateExpenseFilter(ExpenseFilterType type) {
    selectedExpenseType.value = type;
    applyExpenseFilter();
  }

  void applyExpenseFilter() {
    if (selectedExpenseType.value == ExpenseFilterType.all) {
      filteredExpenseList.assignAll(originalExpenseList);
    } else if (selectedExpenseType.value == ExpenseFilterType.other) {
      final values = _expenseMap.values.toList();
      filteredExpenseList.assignAll(
        originalExpenseList.where(
          (expense) => !values.contains(expense.expenseType),
        ),
      );
    } else {
      final selectedLabel = _expenseMap[selectedExpenseType.value];
      filteredExpenseList.assignAll(
        originalExpenseList.where(
          (expense) => expense.expenseType == selectedLabel,
        ),
      );
    }
  }

  String getExpenseFilterLabel(ExpenseFilterType type) {
    if (type == ExpenseFilterType.all) return 'Show All';
    return _expenseMap[type]!;
  }

  // -------------------- ASSET -------------------- //
  static const Map<AssetFilterType, String> _assetMap = {
    AssetFilterType.mutualFunds: 'Mutual funds',
    AssetFilterType.fixedDeposit: 'Fixed Deposit',
    AssetFilterType.gold: 'Gold',
    AssetFilterType.other: 'Others',
  };

  void setAssetData(List<AssetModel> assets) {
    originalAssetList.assignAll(assets);
    applyAssetFilter();
    totalAsset.value = filteredAssetList.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  void updateAssetFilter(AssetFilterType type) {
    selectedAssetType.value = type;
    applyAssetFilter();
  }

  void applyAssetFilter() {
    if (selectedAssetType.value == AssetFilterType.all) {
      filteredAssetList.assignAll(originalAssetList);
    } else if (selectedAssetType.value == AssetFilterType.other) {
      final values = _assetMap.values.toList();
      filteredAssetList.assignAll(
        originalAssetList.where(
          (asset) => !values.contains(asset.investmentCategory),
        ),
      );
    } else {
      final selectedLabel = _assetMap[selectedAssetType.value];
      filteredAssetList.assignAll(
        originalAssetList.where(
          (asset) => asset.investmentCategory == selectedLabel,
        ),
      );
    }
  }

  String getAssetFilterLabel(AssetFilterType type) {
    if (type == AssetFilterType.all) return 'Show All';
    return _assetMap[type]!;
  }
}
