import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealth_app/presentation/controllers/dashboard_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class InteractivePieChart extends StatefulWidget {
  const InteractivePieChart({super.key});

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final List<_PieData> data = [
        _PieData('Income', controller.totalIncome.value, Colors.green),
        _PieData('Investment', controller.totalInvestment.value, Colors.orange),
        _PieData('Net Worth', controller.netWorth.value, Colors.blue),
        _PieData('Expense', controller.totalExpense.value, Colors.red),
      ];

      final double total = data.fold(0, (sum, item) => sum + item.value);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.lineColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Wealth Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.mainFontColor,
              ),
            ),
            const SizedBox(height: 20),

            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          if (response == null ||
                              response.touchedSection == null) {
                            setState(() {
                              touchedIndex = null;
                            });
                            return;
                          }

                          if (event is FlTapDownEvent ||
                              event is FlLongPressStart) {
                            setState(() {
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          }

                          if (event is FlTapUpEvent ||
                              event is FlPanEndEvent ||
                              event is FlLongPressEnd ||
                              event is FlPointerExitEvent) {
                            setState(() {
                              touchedIndex = null;
                            });
                          }
                        },
                      ),
                      sections: List.generate(data.length, (i) {
                        double actualPercent =
                            total == 0 ? 0 : (data[i].value / total) * 100;

                        double displayPercent =
                            actualPercent < 3 && actualPercent > 0
                                ? 3
                                : actualPercent;

                        return PieChartSectionData(
                          color: data[i].color,
                          value: displayPercent,
                          title: '${actualPercent.toStringAsFixed(1)}%',
                          titleStyle: TextStyle(
                            color: context.mainFontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          radius: touchedIndex == i ? 70 : 67,
                        );
                      }),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 300),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),

                  if (touchedIndex != null &&
                      touchedIndex! >= 0 &&
                      touchedIndex! < data.length)
                    Positioned(
                      bottom: 0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: data[touchedIndex!].color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${data[touchedIndex!].label}: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: context.mainFontColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '₹${data[touchedIndex!].value.toStringAsFixed(2)} ',
                                            // '(${(total == 0 ? 0 : (data[touchedIndex!].value / total) * 100).toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: context.mainFontColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  data.map((item) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: context.mainFontColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}
