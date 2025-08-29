import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/presentation/screens/subscreens/add_income_screen.dart';
import 'package:wealth_app/presentation/widgets/dot_loader.dart';
import 'package:wealth_app/presentation/widgets/network_widget.dart';
import 'package:wealth_app/presentation/widgets/universal_scaffold.dart';

class IncomeOverviewScreen extends StatefulWidget {
  const IncomeOverviewScreen({super.key});

  @override
  State<IncomeOverviewScreen> createState() => _IncomeOverviewScreenState();
}

class _IncomeOverviewScreenState extends State<IncomeOverviewScreen> {
  final incomeController = Get.find<IncomeController>();
  final filterController = Get.put(FilterController());
  String? dbUserId;

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return "${date.day}-${date.month}-${date.year}";
    } catch (e) {
      return rawDate;
    }
  }

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadDbUserIdAndFetchData();
  }

  Future<void> _loadDbUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    dbUserId = prefs.getString('DBid');
    if (dbUserId != null) {
      await _fetchData();
    } else {
      debugPrint("❌ DBid not found in SharedPreferences");
    }
  }

  Future<void> _fetchData() async {
    if (dbUserId == null) return;
    Get.dialog(DotLoader(), barrierDismissible: false);
    final result = await incomeController.fetchIncomes(dbUserId!);

    if (result['success'] == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Failed to fetch income data."),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      filterController.setIncomeData(incomeController.incomeList);
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;

    return NetworkAwareWidget(
      child: UniversalScaffold(
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
                  _buildHeaderSection(),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildCardTile(
                      "₹${incomeController.totalIncome.value}",
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListHeader(),
                  const SizedBox(height: 12),
                  _buildIncomeSection(mediaWidth, mediaHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
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
              style: TextStyle(fontSize: 12, color: context.mainFontColor),
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
              style: TextStyle(fontSize: 12, color: context.mainFontColor),
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
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddIncomeScreen()),
                    ).then((_) {
                      _fetchData();
                    }),
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.buttonColor,
                foregroundColor: context.buttonTextColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Add Income"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardTile(String amount) {
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

  Widget _buildListHeader() {
    return Row(
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
          onTap: () => _showIncomeFilterBottomSheet(context),
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
    );
  }

  Widget _buildIncomeSection(double mediaWidth, double mediaHeight) {
    return Obx(() {
      final incomeList = filterController.filteredIncomeList;

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
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Income",
                    style: TextStyle(
                      color: context.mainFontColor,
                      fontWeight: AppTextStyle.mediumWeight,
                    ),
                  ),
                  Text(
                    "Amount",
                    style: TextStyle(
                      color: context.mainFontColor,
                      fontWeight: AppTextStyle.mediumWeight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child:
                  incomeList.isEmpty
                      ? Center(
                        child: Text(
                          "No income available",
                          style: TextStyle(color: context.mainFontColor),
                        ),
                      )
                      : ListView.builder(
                        itemCount: incomeList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final income = incomeList[index];
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/rupee.svg',
                                          height: 22,
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
                                                income.incomeType,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : context
                                                              .mainFontColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(income.startDate),
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
                                          "₹${income.amount.toStringAsFixed(2)}",
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
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(10),
                                            ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _infoRow(
                                            "Period",
                                            income.period,
                                            context,
                                          ),
                                          _infoRow(
                                            "Start Date",
                                            _formatDate(income.startDate),
                                            context,
                                          ),
                                          _infoRow(
                                            "End Date",
                                            _formatDate(income.endDate),
                                            context,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // TextButton.icon(
                                              //   onPressed: () {
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //         builder:
                                              //             (_) =>
                                              //                 AddIncomeScreen(
                                              //                   isEdit: true,
                                              //                   incomeToEdit:
                                              //                       income,
                                              //                 ),
                                              //       ),
                                              //     );
                                              //   },
                                              //   icon: const Icon(
                                              //     Icons.edit,
                                              //     color: Colors.blue,
                                              //   ),
                                              //   label: const Text(
                                              //     "Edit",
                                              //     style: TextStyle(
                                              //       color: Colors.blue,
                                              //     ),
                                              //   ),
                                              // ),

                                              TextButton.icon(
                                                onPressed: () async {
                                                  final confirmed = await showDialog<
                                                    bool
                                                  >(
                                                    context: context,
                                                    builder:
                                                        (ctx) => AlertDialog(
                                                          title: const Text(
                                                            "Confirm Deletion",
                                                          ),
                                                          content: const Text(
                                                            "Are you sure you want to delete this income?",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(
                                                                        false,
                                                                      ),
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                  color:
                                                                      context
                                                                          .mainFontColor,
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(
                                                                        true,
                                                                      ),
                                                              child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );

                                                  if (confirmed == true) {
                                                    final result =
                                                        await incomeController
                                                            .deleteIncome(
                                                              income.id,dbUserId!
                                                            );
                                                    if (result['success'] ==
                                                        true) {
                                                      setState(
                                                        () =>
                                                            selectedIndex = -1,
                                                      );
                                                      await _fetchData();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Income deleted successfully.",
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            result['message'] ??
                                                                'Failed to delete income.',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                label: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoRow(String label, String value, BuildContext context) {
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

  void _showIncomeFilterBottomSheet(BuildContext context) {
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
              children:
                  IncomeFilterType.values.map((type) {
                    final selected =
                        filterController.selectedIncomeType.value == type;
                    return ListTile(
                      leading: Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color:
                            selected
                                ? context.buttonColor
                                : context.placeholderColor,
                      ),
                      title: Text(
                        filterController.getIncomeFilterLabel(type),
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
