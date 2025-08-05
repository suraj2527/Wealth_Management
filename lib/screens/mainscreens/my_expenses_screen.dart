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
import 'package:wealth_app/widgets/network_widget.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:intl/intl.dart';

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({super.key});

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  int selectedIndex = -1;
  bool showFullList = false;
  final userId = Get.find<AuthController>().dbUserId.value;
  final ExpenseController expenseController = Get.put(ExpenseController());
  final FilterController filterController = Get.find<FilterController>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ExpenseModel expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text(
              "Are you sure you want to delete this expense?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final result = await expenseController.deleteExpense(expense.Id);
      debugPrint('😍😎😎$expense.Id');

      if (result['success']) {
        setState(() => selectedIndex = -1);
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Expense deleted successfully."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete expense.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
    final currentYear = DateTime.now().year;

    return NetworkAwareWidget(
      child: UniversalScaffold(
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
                    .where((e) {
                      try {
                        final parsedDate = DateTime.parse(e.startDate);
                        return parsedDate.year == currentYear;
                      } catch (e) {
                        return false;
                      }
                    })
                    .fold<double>(0.0, (sum, e) => sum + e.amount);
      
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
                fontSize: 18,
                fontWeight: AppTextStyle.semiBold,
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
            fontSize: 18,
            fontWeight: AppTextStyle.semiBold,
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
    final visibleExpenses = showFullList ? expenses : expenses.take(4).toList();

    return Container(
      width: mediaWidth * 0.93,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children:
                  visibleExpenses.isEmpty
                      ? [
                        Center(
                          child: Text(
                            "No expense found",
                            style: TextStyle(color: context.mainFontColor),
                          ),
                        ),
                      ]
                      : visibleExpenses.asMap().entries.map((entry) {
                        final index = entry.key;
                        final expense = entry.value;
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap:
                              () => setState(() {
                                selectedIndex = isSelected ? -1 : index;
                              }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? context.buttonColor
                                      : context.fieldColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/rupee.svg',
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          isSelected
                                              ? Colors.white
                                              : context.buttonColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${expense.expenseType} - ${expense.subCategory}",
                                              style: TextStyle( 
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : context.mainFontColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              () {
                                                try {
                                                  final parsedDate =
                                                      DateTime.parse(
                                                        expense.startDate,
                                                      );
                                                  return DateFormat(
                                                    'dd MMM yyyy',
                                                  ).format(parsedDate);
                                                } catch (_) {
                                                  return expense
                                                          .startDate
                                                          .isNotEmpty
                                                      ? expense.startDate
                                                      : 'No Date';
                                                }
                                              }(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    isSelected
                                                        ? Colors.white70
                                                        : context
                                                            .placeholderColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "₹${expense.amount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : context.mainFontColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildDetailRow(
                                          "Sub Category",
                                          expense.subCategory,
                                          context,
                                        ),
                                        _buildDetailRow(
                                          "Period",
                                          expense.period,
                                          context,
                                        ),
                                        _buildDetailRow(
                                          "Annual Increment %",
                                          "${expense.expectedAnnualIncrementPercentage.toStringAsFixed(2)}%",
                                          context,
                                        ),
                                        _buildDetailRow(
                                          "Is Recurring",
                                          expense.isRecurring ? "Yes" : "No",
                                          context,
                                        ),
                                        _buildDetailRow(
                                          "Year",
                                          expense.year.toString(),
                                          context,
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            label: const Text("Delete"),
                                            onPressed:
                                                () => _showDeleteConfirmation(
                                                  context,
                                                  expense,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
            ),
          ),
          if (expenses.length > 4)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => showFullList = !showFullList),
                icon: Icon(
                  showFullList ? Icons.expand_less : Icons.expand_more,
                  color: context.buttonColor,
                ),
                label: Text(
                  showFullList ? "View Less" : "View More",
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

Widget _buildDetailRow(String label, String value, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.mainFontColor.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: context.mainFontColor)),
        ),
      ],
    ),
  );
}
