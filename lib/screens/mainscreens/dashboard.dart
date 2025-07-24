import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/font_sizes.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/dashboard_controller.dart';
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
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App',style: TextStyle(fontWeight: AppTextStyle.mediumWeight),),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.mainFontColor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: AppColors.buttonColor),
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
              const Text(
                'Wealth Summary',
                style: TextStyle(
                  fontWeight: AppTextStyle.bold,
                  fontSize: FontSizes.heading,
                ),
              ),
              const SizedBox(height: 6),
              // const Text(
              //   // 'Here is a quick glance at your financial status.',
              //   // style: TextStyle(color: Colors.grey, fontSize: FontSizes.body),
              // ),
              const SizedBox(height: 20),

              Obx(() {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Total Net Worth
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Net Worth',
                          style: TextStyle(
                             fontWeight: AppTextStyle.mediumWeight,
                            fontSize: FontSizes.heading2,
                            color: AppColors.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SummaryCard(
                          amount: dashboardController.netWorth.value,
                          width: mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                        ),
                      ],
                    ),

                    // Total Income
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Income',
                          style: TextStyle(
                              fontWeight: AppTextStyle.mediumWeight,
                            fontSize: FontSizes.heading2,
                            color: AppColors.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SummaryCard(
                          amount: dashboardController.totalIncome.value,
                          width: mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                        ),
                      ],
                    ),

                    // Total Investment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Investment',
                          style: TextStyle(
                            fontWeight: AppTextStyle.mediumWeight,
                            fontSize: FontSizes.heading2,
                            color: AppColors.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SummaryCard(
                          amount: dashboardController.totalInvestment.value,
                          width: mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                        ),
                      ],
                    ),

                    // Total Expense
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(
                              fontWeight: AppTextStyle.mediumWeight,
                            fontSize: FontSizes.heading2,
                            color: AppColors.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SummaryCard(
                          amount: dashboardController.totalExpense.value,
                          width: mediaWidth > 600
                              ? mediaWidth / 2 - 28
                              : double.infinity,
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 30),
              const Divider(color: AppColors.linecolor, thickness: 0.4),
              const SizedBox(height: 20),

              const Text(
                'Wealth Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.bold,
                  fontSize: FontSizes.heading1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Based on current data trends',
                style: TextStyle(color: Colors.grey, fontSize: FontSizes.body),
              ),
              const SizedBox(height: 24),

              const Text(
                'Your Net Worth Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.semiBold,
                  fontSize: FontSizes.heading1,
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
              const Text(
                'Your Income Projection',
                style: TextStyle(
                  fontWeight: AppTextStyle.semiBold,
                  fontSize: FontSizes.heading1,
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
              const Center(
                child: Text(
                  '@2023 Dynamics Monk All Rights Reserved.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
