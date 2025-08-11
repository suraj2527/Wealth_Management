import 'dart:math';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealth_app/presentation/controllers/filter_controller.dart';
import 'package:wealth_app/presentation/controllers/income_controller.dart';
import 'package:wealth_app/presentation/controllers/expense_controller.dart';
import 'package:wealth_app/presentation/controllers/asset_controller.dart';

class DashboardController extends GetxController {
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var totalInvestment = 0.0.obs;
  var netWorth = 0.0.obs;

  RxList<FlSpot> netWorthGraphData =
      <FlSpot>[
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
      ].obs;

  RxList<FlSpot> incomeGraphData =
      <FlSpot>[
        FlSpot(0, 0),
        FlSpot(1, 0),
        FlSpot(2, 0),
        FlSpot(3, 0),
        FlSpot(4, 0),
        FlSpot(5, 0),
      ].obs;

  RxList<PieChartSectionData> incomeVsExpensePieData =
      <PieChartSectionData>[].obs;
  RxList<PieChartSectionData> assetDistributionPieData =
      <PieChartSectionData>[].obs;
  RxList<PieChartSectionData> netWorthBreakdownPieData =
      <PieChartSectionData>[].obs;

  final FilterController _filter = Get.find<FilterController>();
  final IncomeController _incomeController = Get.find<IncomeController>();
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final AssetController _assetController = Get.find<AssetController>();

  String? _userId;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();

    ever<double>(_filter.totalIncome, (v) {
      totalIncome.value = v;
      _recalcNetWorth();
      updatePieCharts();
    });

    ever<double>(_filter.totalExpense, (v) {
      totalExpense.value = v;
      _recalcNetWorth();
      updatePieCharts();
    });

    ever<double>(_filter.totalAsset, (v) {
      totalInvestment.value = v;
      _recalcNetWorth();
      updatePieCharts();
    });
  }

  Future<void> initializeDashboard(String userId, {bool force = false}) async {
    if (!force && _isInitialized && _userId == userId) {
      return;
    }

    try {
      _userId = userId;
      _isInitialized = true;

      await _incomeController.fetchIncomes(userId);
      await _expenseController.fetchExpenses(userId);
      await _assetController.fetchAssets(userId);

      _filter.totalIncome.value = _incomeController.totalIncome.value;
      _filter.totalExpense.value = _expenseController.expenseList.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );
      _filter.totalAsset.value = _assetController.assetList.fold(
        0.0,
        (sum, a) => sum + a.amount,
      );

      updateIncomeGraph(_generateIncomeProjection());
      updateNetWorthGraph(_generateNetWorthProjection());
      _recalcNetWorth();
      updatePieCharts();
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  void updateNetWorthGraph(List<FlSpot> spots) =>
      netWorthGraphData.assignAll(spots);

  void updateIncomeGraph(List<FlSpot> spots) =>
      incomeGraphData.assignAll(spots);

  void _recalcNetWorth() {
    netWorth.value =
        totalIncome.value + totalInvestment.value - totalExpense.value;
  }

  // ---------------- PIE CHART UPDATES ---------------- //

  void updatePieCharts() {
    incomeVsExpensePieData.assignAll(_generateIncomeVsExpenseData());
    assetDistributionPieData.assignAll(_generateAssetDistributionData());
    netWorthBreakdownPieData.assignAll(_generateNetWorthBreakdownData());
  }

  List<PieChartSectionData> _generateIncomeVsExpenseData() {
    double income = totalIncome.value;
    double expense = totalExpense.value;
    double total = income + expense;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: income,
        color: Colors.blue,
        title: 'Income',
        radius: 40,
      ),
      PieChartSectionData(
        value: expense,
        color: Colors.orange,
        title: 'Expense',
        radius: 40,
      ),
    ];
  }

  List<PieChartSectionData> _generateAssetDistributionData() {
    if (_assetController.assetList.isEmpty) return [];

    return _assetController.assetList.map((asset) {
      return PieChartSectionData(
        value: asset.amount,
        title: asset.investmentFundName,
        color: _getRandomColor(asset.investmentFundName.hashCode),
        radius: 40,
      );
    }).toList();
  }

  List<PieChartSectionData> _generateNetWorthBreakdownData() {
    double income = totalIncome.value;
    double investment = totalInvestment.value;
    double expense = totalExpense.value;
    double total = income + investment + expense;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: income,
        color: Colors.green,
        title: 'Income',
        radius: 40,
      ),
      PieChartSectionData(
        value: investment,
        color: Colors.purple,
        title: 'Investment',
        radius: 40,
      ),
      PieChartSectionData(
        value: expense,
        color: Colors.red,
        title: 'Expense',
        radius: 40,
      ),
    ];
  }

  Color _getRandomColor(int seed) {
    final Random random = Random(seed);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
  }

  // ---------------- INCOME PROJECTION ---------------- //
  List<FlSpot> _generateIncomeProjection() {
    final now = DateTime.now();
    final years = List.generate(6, (i) => now.year + i);
    final projection = <FlSpot>[];

    for (int i = 0; i < years.length; i++) {
      final year = years[i];
      double totalIncomeForYear = 0.0;

      for (var income in _filter.filteredIncomeList) {
        final startYear = DateTime.tryParse(income.startDate)?.year;
        if (startYear != null && startYear <= year) {
          int yearsPassed = year - startYear;
          double incrementFactor =
              1 + (income.expectedAnnualIncrementPercentage / 100);
          double projectedAmount =
              income.amount * pow(incrementFactor, yearsPassed);
          totalIncomeForYear += projectedAmount;
        }
      }

      projection.add(FlSpot(i.toDouble(), totalIncomeForYear));
    }

    return projection;
  }

  // ---------------- NET WORTH PROJECTION ---------------- //
  List<FlSpot> _generateNetWorthProjection() {
    final now = DateTime.now();
    final years = List.generate(6, (i) => now.year + i);
    final projection = <FlSpot>[];

    for (int i = 0; i < years.length; i++) {
      final year = years[i];
      double income = 0.0;
      double expense = 0.0;

      for (var incomeItem in _filter.filteredIncomeList) {
        final startYear = DateTime.tryParse(incomeItem.startDate)?.year;
        if (startYear != null && startYear <= year) {
          int yearsPassed = year - startYear;
          double incrementFactor =
              1 + (incomeItem.expectedAnnualIncrementPercentage / 100);
          income += incomeItem.amount * pow(incrementFactor, yearsPassed);
        }
      }

      for (var expenseItem in _filter.filteredExpenseList) {
        final startYear = DateTime.tryParse(expenseItem.startDate)?.year;
        if (startYear != null && startYear <= year) {
          int yearsPassed = year - startYear;
          double incrementFactor =
              1 + (expenseItem.expectedAnnualIncrementPercentage / 100);
          expense += expenseItem.amount * pow(incrementFactor, yearsPassed);
        }
      }

      final assetValue = _filter.totalAsset.value;
      double netWorth = income + assetValue - expense;

      projection.add(FlSpot(i.toDouble(), netWorth));
    }

    return projection;
  }
}
