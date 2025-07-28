import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/expense_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';
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
          backgroundColor: context.fieldColor,
          color: context.mainFontColor,
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
                  _buildHeaderWithFilter(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Expenses",
              style: TextStyle(
                fontSize: 22,
                fontWeight: AppTextStyle.bold,
                color: context.mainFontColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Your Overall Expenses",
              style: TextStyle(fontSize: 12, color: context.placeholderColor),
            ),
            const SizedBox(height: 40),
            Text(
              "Current Year Expenses",
              style: TextStyle(
                fontWeight: AppTextStyle.semiBold,
                fontSize: 18,
                color: context.mainFontColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Your Total Expenses",
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
              label: Text(
                "Refresh",
                style: TextStyle(color: context.buttonColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.buttonColor),
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
                  backgroundColor: context.buttonColor,
                  foregroundColor: context.buttonTextColor,
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

  Widget _buildHeaderWithFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Expense List",
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
                "Expense Filter",
                style: TextStyle(color: context.buttonColor),
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
      backgroundColor: context.fieldColor,
      context: context,
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
                        color:
                            selected
                                ? context.buttonColor
                                : context.borderColor,
                      ),
                      title: Text(
                        filterController.getFilterLabel(type),
                        style: TextStyle(
                          color: context.mainFontColor,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
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
        color: context.cardColor,
        border: Border.all(color: context.borderColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category",
                  style: TextStyle(color: context.mainFontColor),
                ),
                Text("Amount", style: TextStyle(color: context.mainFontColor)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                expenses.isEmpty
                    ? Center(
                      child: Text(
                        "No expense found",
                        style: TextStyle(color: context.mainFontColor),
                      ),
                    )
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
                                      ? context.buttonColor
                                      : context.fieldColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: ListTile(
                              leading: SvgPicture.asset(
                                'assets/icons/rupee.svg',
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? Colors.white
                                      : context.buttonColor,
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
                                      isSelected
                                          ? Colors.white
                                          : context.mainFontColor,
                                ),
                              ),
                              subtitle: Text(
                                expense.date,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white70
                                          : context.placeholderColor,
                                ),
                              ),
                              trailing: Text(
                                "₹${expense.amount}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : context.mainFontColor,
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
              child: Text(
                "View More",
                style: TextStyle(color: context.buttonColor),
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
        color: context.fieldColor,
        border: Border.all(color: context.borderColor.withOpacity(0.01)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: Text(
        amount,
        style: TextStyle(
          fontSize: 20,
          fontWeight: AppTextStyle.semiBold,
          color: context.mainFontColor,
        ),
      ),
    );
  }
}
