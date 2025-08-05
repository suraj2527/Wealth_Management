import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/expense_controller.dart';
import 'package:wealth_app/controllers/asset_controller.dart';

class DashboardController extends GetxController {
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var totalInvestment = 0.0.obs;
  var netWorth = 0.0.obs;

  RxList<FlSpot> netWorthGraphData = <FlSpot>[
    FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0),
    FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0),
  ].obs;

  RxList<FlSpot> incomeGraphData = <FlSpot>[
    FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0),
    FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0),
  ].obs;

  final FilterController _filter = Get.find<FilterController>();
  final IncomeController _incomeController = Get.find<IncomeController>();
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final AssetController _assetController = Get.find<AssetController>();

  String? _userId;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();

    // Listen to filter changes and recalculate
    ever<double>(_filter.totalIncome, (v) {
      totalIncome.value = v;
      _recalcNetWorth();
    });

    ever<double>(_filter.totalExpense, (v) {
      totalExpense.value = v;
      _recalcNetWorth();
    });

    ever<double>(_filter.totalAsset, (v) {
      totalInvestment.value = v;
      _recalcNetWorth();
    });
  }

  /// 🟢 Only initializes once per user (or if forced)
  Future<void> initializeDashboard(String userId, {bool force = false}) async {
    if (_isInitialized && _userId == userId && !force) {
      return; // prevent re-initialization
    }

    _userId = userId;
    _isInitialized = true;

    // Fetch and populate data
    await _incomeController.fetchIncomes(userId);
    await _expenseController.fetchExpenses(userId);
    await _assetController.fetchAssets(userId);

    _filter.totalIncome.value = _incomeController.totalIncome.value;
    _filter.totalExpense.value =
        _expenseController.expenseList.fold(0.0, (sum, e) => sum + e.amount);
    _filter.totalAsset.value =
        _assetController.assetList.fold(0.0, (sum, a) => sum + a.amount);

    _recalcNetWorth();
  }

  void updateNetWorthGraph(List<FlSpot> spots) =>
      netWorthGraphData.assignAll(spots);

  void updateIncomeGraph(List<FlSpot> spots) =>
      incomeGraphData.assignAll(spots);

  void _recalcNetWorth() {
    netWorth.value =
        totalIncome.value + totalInvestment.value - totalExpense.value;
  }
}
