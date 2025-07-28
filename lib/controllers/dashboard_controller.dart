import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardController extends GetxController {
  var netWorth = '0'.obs;
  var totalIncome = '0'.obs;
  var totalInvestment = '0'.obs;
  var totalExpense = '0'.obs;

  RxList<FlSpot> netWorthGraphData =
      <FlSpot>[
        FlSpot(0, 3),
        FlSpot(4, 0),
        FlSpot(2, 0),
        FlSpot(5, 0),
        FlSpot(8, 0),
        FlSpot(6, 0),
      ].obs;

  RxList<FlSpot> incomeGraphData =
      <FlSpot>[
        FlSpot(0, 50),
        FlSpot(1, 150),
        FlSpot(2, 250),
        FlSpot(3, 350),
        FlSpot(4, 450),
        FlSpot(5, 600),
      ].obs;

  void updateNetWorth(String value) => netWorth.value = value;
  void updateTotalIncome(String value) => totalIncome.value = value;
  void updateTotalInvestment(String value) => totalInvestment.value = value;
  void updateTotalExpense(String value) => totalExpense.value = value;

  void updateNetWorthGraph(List<FlSpot> spots) =>
      netWorthGraphData.assignAll(spots);

  void updateIncomeGraph(List<FlSpot> spots) =>
      incomeGraphData.assignAll(spots);
}
