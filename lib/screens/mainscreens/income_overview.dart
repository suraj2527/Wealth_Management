import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/screens/subscreens/add_income_screen.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

class IncomeOverviewScreen extends StatefulWidget {
  const IncomeOverviewScreen({super.key});

  @override
  State<IncomeOverviewScreen> createState() => _IncomeOverviewScreenState();
}

class _IncomeOverviewScreenState extends State<IncomeOverviewScreen> {
  final incomeController = Get.find<IncomeController>();
  final filterController = Get.put(FilterController());
  final userId = Get.find<AuthController>().userId.value;

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await incomeController.fetchIncomes(userId);
    await incomeController.fetchTotalIncome(userId);
    filterController.setIncomeData(incomeController.incomeList);
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    return UniversalScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          backgroundColor: context.fieldColor,
          color: context.mainFontColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Income Overview",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Your complete income summary",
                          style: TextStyle(fontSize: 12, color: context.placeholderColor),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Total Income",
                          style: TextStyle(
                            fontWeight: AppTextStyle.semiBold,
                            fontSize: 18,
                            color: context.mainFontColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Your Current Income",
                          style: TextStyle(fontSize: 12, color: context.placeholderColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _fetchData,
                          icon: Icon(Icons.refresh, color: context.buttonColor),
                          label: Text("Refresh", style: TextStyle(color: context.buttonColor)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.buttonColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.buttonColor,
                            foregroundColor: context.buttonTextColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Add Income"),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Obx(() => _cardTile("₹${incomeController.totalIncome.value}")),
                const SizedBox(height: 16),

                /// Income List Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Income List",
                      style: TextStyle(
                        fontWeight: AppTextStyle.semiBold,
                        fontSize: 18,
                        color: context.mainFontColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Row(
                        children: [
                          Text(
                            "Income Filter",
                            style: TextStyle(color: context.buttonColor),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/icons/filter.svg', height: 14),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Income List
                Container(
                  width: mediaWidth * 0.93,
                  height: mediaHeight * 0.5,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.borderColor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() {
                    final incomeList = filterController.filteredIncomeList;

                    if (incomeList.isEmpty) {
                      return Center(
                        child: Text("No Income available", style: TextStyle(color: context.mainFontColor)),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Income's", style: TextStyle(color: context.mainFontColor)),
                              Text("Amount", style: TextStyle(color: context.mainFontColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: incomeList.length,
                            itemBuilder: (context, index) {
                              final income = incomeList[index];
                              final isSelected = index == selectedIndex;

                              return GestureDetector(
                                onTap: () => setState(() => selectedIndex = index),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? context.buttonColor : context.fieldColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ListTile(
                                    leading: SvgPicture.asset(
                                      'assets/icons/rupee.svg',
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        isSelected ? Colors.white : context.buttonColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    title: Text(
                                      "${income.source} (${income.type})",
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : context.mainFontColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      income.date,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : context.mainFontColor,
                                      ),
                                    ),
                                    trailing: Text(
                                      "₹${income.amount}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isSelected ? Colors.white : context.mainFontColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text("View More", style: TextStyle(color: context.buttonColor)),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardTile(String amount) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.07,
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.02,
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      decoration: BoxDecoration(
        color: context.fieldColor,
        border: Border.all(color: context.borderColor.withOpacity(0.01)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          amount,
          style: TextStyle(
            fontSize: 20,
            fontWeight: AppTextStyle.semiBold,
            color: context.mainFontColor,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: context.fieldColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: FilterType.values.map((type) {
                final selected = filterController.incomeFilterType.value == type;
                return ListTile(
                  leading: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? context.buttonColor : context.placeholderColor,
                  ),
                  title: Text(
                    filterController.getFilterLabel(type),
                    style: TextStyle(color: context.mainFontColor),
                  ),
                  onTap: () {
                    filterController.updateIncomeFilter(type);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          }),
        );
      },
    );
  }
}
