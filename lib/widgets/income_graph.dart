import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class IncomeGraph extends StatelessWidget {
  const IncomeGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor.withOpacity(0.01)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: context.buttonColor, // previously AppColors.graphcolor
              belowBarData: BarAreaData(show: false),
              spots: const [
                FlSpot(1, 2),
                FlSpot(2, 3),
                FlSpot(3, 4),
                FlSpot(4, 5),
                FlSpot(5, 6),
                FlSpot(6, 7),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
