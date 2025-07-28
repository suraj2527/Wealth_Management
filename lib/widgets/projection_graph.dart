import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class ProjectionGraph extends StatelessWidget {
  final bool showLegend;
  final String? legendLeft;
  final String? legendRight;
  final bool isIncomeGraph;

  const ProjectionGraph({
    super.key,
    this.showLegend = false,
    this.legendLeft,
    this.legendRight,
    this.isIncomeGraph = false,
  });

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.find();

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor.withOpacity(0.01)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              final dataPoints =
                  isIncomeGraph
                      ? dashboardController.incomeGraphData
                      : dashboardController.netWorthGraphData;

              return LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      color: context.buttonColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: context.buttonColor.withOpacity(0.1),
                      ),
                      isStrokeCapRound: true,
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              );
            }),
          ),
          if (showLegend) const SizedBox(height: 14),
          if (showLegend)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _legendDot(context.buttonColor, legendLeft ?? "Current"),
                _legendDot(
                  context.buttonColor.withOpacity(0.4),
                  legendRight ?? "Projected",
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
