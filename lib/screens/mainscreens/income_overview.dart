import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
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
          backgroundColor: AppColors.fieldcolor,
          color: Colors.black,
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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Income Overview",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Your complete income summary",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 40),
                        Text(
                          "Total Income",
                          style: TextStyle(
                            fontWeight: AppTextStyle.semiBold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Your Current Income",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                          label: const Text("Refresh", style: TextStyle(color: Colors.deepPurple)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepPurple),
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
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
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
                    const Text(
                      "Income List",
                      style: TextStyle(fontWeight: AppTextStyle.semiBold, fontSize: 18),
                    ),
                    InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      child: Row(
                        children: [
                          Text(
                                 "Income Filter",
                            style: const TextStyle(color: Colors.deepPurple),
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
                    border: Border.all(color: AppColors.bordercolor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() {
                    final incomeList = filterController.filteredIncomeList;

                    if (incomeList.isEmpty) {
                      return const Center(child: Text("No Income available"));
                    }

                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Income's", style: TextStyle(color: AppColors.mainFontColor)),
                              Text("Amount", style: TextStyle(color: AppColors.mainFontColor)),
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
                                    color: isSelected
                                        ? AppColors.buttonColor
                                        : AppColors.fieldcolor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ListTile(
                                    leading: SvgPicture.asset(
                                      'assets/icons/rupee.svg',
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        isSelected ? Colors.white : Colors.deepPurple,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    title: Text(
                                      "${income.source} (${income.type})",
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      income.date,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    trailing: Text(
                                      "₹${income.amount}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isSelected ? Colors.white : Colors.black,
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
                            child: const Text("View More", style: TextStyle(color: Colors.deepPurple)),
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
        color: AppColors.fieldcolor,
        border: Border.all(color: AppColors.bordercolor.withOpacity(0.01)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          amount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: AppTextStyle.semiBold,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.fieldcolor,
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
                    color: selected ? Colors.deepPurple : Colors.grey,
                  ),
                  title: Text(filterController.getFilterLabel(type)),
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
