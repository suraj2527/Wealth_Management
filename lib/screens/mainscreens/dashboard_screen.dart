// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/font_sizes.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/widgets/projection_graph.dart';
import 'package:wealth_app/widgets/summary_card.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final mediaWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: context.fieldColor,
                  title: const Text(
                    'Exit App',
                    style: TextStyle(fontWeight: AppTextStyle.mediumWeight),
                  ),
                  content: const Text('Are you sure you want to exit the app?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: context.mainFontColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
          );

          if (shouldExit ?? false) {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          }
        }
      },
      child: UniversalScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wealth Summary',
                style: TextStyle(
                  fontWeight: AppTextStyle.bold,
                  fontSize: FontSizes.heading,
                  color: context.mainFontColor,
                ),
              ),
              const SizedBox(height: 6),

              const SizedBox(height: 20),
              Obx(() {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildSummaryItem(
                      context,
                      title: 'Total Net Worth',
                      amount: dashboardController.netWorth.value,
                      width:
                          mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                    ),
                    _buildSummaryItem(
                      context,
                      title: 'Total Income',
                      amount: dashboardController.totalIncome.value,
                      width:
                          mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                    ),
                    _buildSummaryItem(
                      context,
                      title: 'Total Investment',
                      amount: dashboardController.totalInvestment.value,
                      width:
                          mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                    ),
                    _buildSummaryItem(
                      context,
                      title: 'Total Expense',
                      amount: dashboardController.totalExpense.value,
                      width:
                          mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 30),
              Divider(color: context.lineColor, thickness: 0.4),
              const SizedBox(height: 20),

              Text(
                'Wealth Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.bold,
                  fontSize: FontSizes.heading1,
                  color: context.mainFontColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Based on current data trends',
                style: TextStyle(
                  color: context.placeholderColor,
                  fontSize: FontSizes.body,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Your Net Worth Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.semiBold,
                  fontSize: FontSizes.heading1,
                  color: context.mainFontColor,
                ),
              ),
              const SizedBox(height: 12),

              const ProjectionGraph(
                showLegend: true,
                legendLeft: 'Current',
                legendRight: 'Projected',
                isIncomeGraph: false,
              ),

              const SizedBox(height: 24),
              Text(
                'Your Income Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.semiBold,
                  fontSize: FontSizes.heading1,
                  color: context.mainFontColor,
                ),
              ),
              const SizedBox(height: 12),

              const ProjectionGraph(
                showLegend: true,
                legendLeft: 'Current',
                legendRight: 'Projected',
                isIncomeGraph: true,
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  '@2023 Dynamics Monk All Rights Reserved.',
                  style: TextStyle(
                    color: context.placeholderColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String title,
    required String amount,
    required double width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: AppTextStyle.mediumWeight,
            fontSize: FontSizes.heading2,
            color: context.mainFontColor,
          ),
        ),
        const SizedBox(height: 6),
        SummaryCard(amount: amount, width: width),
      ],
    );
  }
}
