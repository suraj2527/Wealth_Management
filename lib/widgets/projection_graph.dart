// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:wealth_app/constants/colors.dart';

// class ProjectionGraph extends StatelessWidget {
//   final List<FlSpot> dataPoints;
//   final Color color;
//   final bool showLegend;
//   final String? legendLeft;
//   final String? legendRight;

//   const ProjectionGraph({
//     super.key,
//     required this.dataPoints,
//     this.color = AppColors.graphcolor,
//     this.showLegend = false,
//     this.legendLeft,
//     this.legendRight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 220,
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         // border: Border.all(color: AppColors.bordercolor),
//         border: Border.all(color: AppColors.bordercolor.withOpacity(0.1)),

//         boxShadow: [
//           BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8),
//         ],
//       ),
//       child: Column(
//         children: [
//           Expanded(
//             child: LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: dataPoints,
//                     isCurved: true,
//                     color: color,
//                     barWidth: 3,
//                     dotData: FlDotData(show: true),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: color.withOpacity(0.1),
//                     ),
//                     isStrokeCapRound: true,
//                   ),
//                 ],
//                 titlesData: FlTitlesData(show: false),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(show: false),
//               ),
//             ),
//           ),
//           if (showLegend) const SizedBox(height: 14),
//           if (showLegend)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _legendDot(color, legendLeft ?? "Current"),
//                 _legendDot(color.withOpacity(0.4), legendRight ?? "Projected"),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _legendDot(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';

class ProjectionGraph extends StatelessWidget {
  final bool showLegend;
  final String? legendLeft;
  final String? legendRight;
  final bool isIncomeGraph; // true = income, false = net worth

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordercolor.withOpacity(0.01)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Obx(() {
              final dataPoints = isIncomeGraph
                  ? dashboardController.incomeGraphData
                  : dashboardController.netWorthGraphData;

              return LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      color: AppColors.graphcolor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.graphcolor.withOpacity(0.1),
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
                _legendDot(AppColors.graphcolor, legendLeft ?? "Current"),
                _legendDot(AppColors.graphcolor.withOpacity(0.4), legendRight ?? "Projected"),
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
