import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/expense_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/models/expense_model.dart';
import 'package:wealth_app/screens/subscreens/add_expense_screen.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({super.key});

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  int selectedIndex = -1;

  final userId = Get.find<AuthController>().userId.value;
  final ExpenseController expenseController = Get.put(ExpenseController());
  final FilterController filterController = Get.find<FilterController>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final result = await expenseController.fetchExpenses(userId);
    if (result['success']) {
      filterController.setExpenseData(expenseController.expenseList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final currentYear = DateTime.now().year.toString();

    return UniversalScaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          backgroundColor: AppColors.fieldcolor,
          color: Colors.black,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() {
              final expenses = filterController.filteredExpenseList;
              final totalAmount = expenses
                  .where((e) => e.date.contains(currentYear))
                  .fold<double>(
                    0.0,
                    (sum, e) => sum + (double.tryParse(e.amount) ?? 0.0),
                  );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(),
                  const SizedBox(height: 16),
                  _cardTile("₹${totalAmount.toStringAsFixed(2)}"),
                  const SizedBox(height: 16),
                  _buildHeaderWithFilter(context),
                  const SizedBox(height: 12),
                  _buildExpenseList(expenses, mediaWidth),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Expenses",
              style: TextStyle(fontSize: 22, fontWeight: AppTextStyle.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Your Overall Expenses",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 40),
            Text(
              "Current Year Expenses",
              style: TextStyle(fontWeight: AppTextStyle.semiBold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              "Your Total Expenses",
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
              label: const Text(
                "Refresh",
                style: TextStyle(color: Colors.deepPurple),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.deepPurple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Add Expense",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderWithFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Expense List",
          style: TextStyle(fontWeight: AppTextStyle.semiBold, fontSize: 18),
        ),
        InkWell(
          onTap: () => _showFilterBottomSheet(context),
          child: Row(
            children: [
              Text(
                "Expense Filter",
                style: const TextStyle(color: Colors.deepPurple),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset('assets/icons/filter.svg', height: 14),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      // barrierColor: AppColors.fieldcolor,
      context: context,
      // isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Obx(() {
            return Column(
              
              mainAxisSize: MainAxisSize.min,
              children:
                  FilterType.values.map((type) {
                    final selected =
                        filterController.expenseFilterType.value == type;
                    return ListTile(
                      leading: Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color: selected ? Colors.deepPurple : Colors.grey,
                      ),
                      title: Text(filterController.getFilterLabel(type)),
                      onTap: () {
                        filterController.updateExpenseFilter(type);
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

  Widget _buildExpenseList(List<ExpenseModel> expenses, double mediaWidth) {
    return Container(
      width: mediaWidth * 0.93,
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.bordercolor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category",
                  style: TextStyle(color: AppColors.mainFontColor),
                ),
                Text(
                  "Amount",
                  style: TextStyle(color: AppColors.mainFontColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                expenses.isEmpty
                    ? const Center(child: Text("No expense found"))
                    : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
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
                                "${expense.type} (${expense.natureType})",
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                expense.date,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                              trailing: Text(
                                "₹${expense.amount}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
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
              child: const Text(
                "View More",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ),
        ],
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
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Text(
        amount,
        style: const TextStyle(fontSize: 20, fontWeight: AppTextStyle.semiBold),
      ),
    );
  }
}
