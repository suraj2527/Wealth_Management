import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/api/api_helper.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/controller/asset_controller.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/screen/add_asset_screen.dart';
import 'package:wealth_app/presentation/Authentication/controller/auth_controller.dart';
import 'package:wealth_app/presentation/Dashboard/screen/controller/filter_controller.dart';
import 'package:wealth_app/utils/constants/text_styles.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/presentation/Asset%20&%20Investment/model/asset_model.dart';
import 'package:wealth_app/widgets/dot_loader.dart';
import 'package:wealth_app/presentation/screens/Network/network_widget.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

class MyAssetsAndInvestmentsScreen extends StatefulWidget {
  const MyAssetsAndInvestmentsScreen({super.key});

  @override
  State<MyAssetsAndInvestmentsScreen> createState() =>
      _MyAssetsAndInvestmentsScreenState();
}

class _MyAssetsAndInvestmentsScreenState
    extends State<MyAssetsAndInvestmentsScreen> {
  int selectedIndex = -1;
  bool showFullList = false;

  final userId = Get.find<AuthController>().dbUserId.value;
  final AssetController assetController = Get.put(AssetController());
  final FilterController filterController = Get.find<FilterController>();
  String? dbUserId;


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

  void _confirmDelete(BuildContext context, AssetModel asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Asset"),
            content: const Text("Are you sure you want to delete this asset?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: context.mainFontColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final result = await assetController.deleteAsset(asset.id, userId);
      if (result['success']) {
        setState(() => selectedIndex = -1);
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Asset deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Deletion failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchData() async {
    Get.dialog(DotLoader(), barrierDismissible: false);

    final result = await assetController.fetchAssets(userId);
    if (result['success']) {
      filterController.setAssetData(assetController.assetList);
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> navigateToAddAsset() async {
    final result = await Get.to(() => const AddAssetScreen());
    _fetchData();

    if (result is AssetModel) {
      await http.post(
        Uri.parse(ApiHelper.addAsset()),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(result.toJson()..addAll({'userId': userId})),
      );

      await _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;

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
              child: Obx(() {
                final assets = filterController.filteredAssetList;
                final totalAmount = assets
                    .where((a) => a.amount != null)
                    .fold<double>(0.0, (sum, a) => sum + a.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopSection(),
                    const SizedBox(height: 16),
                    _cardTile("₹${totalAmount.toStringAsFixed(2)}"),
                    const SizedBox(height: 16),
                    _buildHeaderWithFilter(),
                    const SizedBox(height: 12),
                    _buildAssetList(assets, mediaWidth),
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
  return LayoutBuilder(
    builder: (context, constraints) {
      final maxRightWidth = 140.0; // max width for right buttons
      final availableWidth = constraints.maxWidth - maxRightWidth - 8; // 8 for spacing

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          SizedBox(
            width: availableWidth > 0 ? availableWidth : constraints.maxWidth * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Assets &",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: AppTextStyle.bold,
                    color: context.mainFontColor,
                  ),
                ),
                Text(
                  "Investments",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: AppTextStyle.bold,
                    color: context.mainFontColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your Overall Assets Summary",
                  style: TextStyle(fontSize: 12, color: context.mainFontColor),
                ),
                const SizedBox(height: 40),
                Text(
                  "Current Year Investments",
                  style: TextStyle(
                    fontWeight: AppTextStyle.semiBold,
                    fontSize: 18,
                    color: context.mainFontColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "This Year Investments",
                  style: TextStyle(fontSize: 12, color: context.mainFontColor),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), // spacing between columns

          // Right Column (buttons)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxRightWidth),
            child: Column(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: navigateToAddAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.buttonColor,
                    foregroundColor: context.buttonTextColor,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Add Investment",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildHeaderWithFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Assets List",
          style: TextStyle(
            fontWeight: AppTextStyle.semiBold,
            fontSize: 18,
            color: context.mainFontColor,
          ),
        ),
        InkWell(
          onTap: () => _showAssetFilterBottomSheet(context),
          child: Row(
            children: [
              Text(
                "Asset Filter",
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

  void _showAssetFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: context.fieldColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      AssetFilterType.values.map((type) {
                        final selected =
                            filterController.selectedAssetType.value == type;
                        return ListTile(
                          leading: Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                selected
                                    ? context.buttonColor
                                    : context.borderColor,
                          ),
                          title: Text(
                            filterController.getAssetFilterLabel(type),
                            style: TextStyle(
                              color: context.mainFontColor,
                              fontWeight:
                                  selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            filterController.updateAssetFilter(type);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildAssetList(List<AssetModel> assets, double mediaWidth) {
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Assets",
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
                assets.isEmpty
                    ? Center(
                      child: Text(
                        "No Asset available",
                        style: TextStyle(color: context.mainFontColor),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: assets.length,
                      physics: const BouncingScrollPhysics(),

                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap:
                              () => setState(
                                () => selectedIndex = isSelected ? -1 : index,
                              ),
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
                                        'assets/icons/asset_icon.svg',
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
                                              "${asset.investmentCategory} ",
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
                                              "(${_getYear(asset.startDate)})",
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
                                        "₹${asset.amount.toStringAsFixed(2)}",
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
                                        _infoRow(
                                          "Fund Name",
                                          asset.investmentFundName,
                                          context,
                                        ),
                                        _infoRow(
                                          "Start Date",
                                          asset.startDate,
                                          context,
                                        ),
                                        _infoRow(
                                          "End Date",
                                          asset.endDate,
                                          context,
                                        ),
                                        _infoRow(
                                          "Category",
                                          asset.investmentCategory,
                                          context,
                                        ),
                                        _infoRow(
                                          "Sub-Category",
                                          asset.investmentSubCategory,
                                          context,
                                        ),
                                        _infoRow(
                                          "Amount",
                                          "₹${asset.amount.toStringAsFixed(2)}",
                                          context,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // TextButton.icon(
                                            //   onPressed: () {
                                            //     _editAsset(context, asset);
                                            //   },
                                            //   icon: const Icon(
                                            //     Icons.edit_outlined,
                                            //     color: Colors.blue,
                                            //   ),
                                            //   label: const Text(
                                            //     "Edit",
                                            //     style: TextStyle(
                                            //       color: Colors.blue,
                                            //     ),
                                            //   ),
                                            // ),
                                            // const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed:
                                                  () => _confirmDelete(
                                                    context,
                                                    asset,
                                                  ),
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
  }

  String _getYear(String startDate) {
    try {
      final date = DateTime.parse(startDate);
      return date.year.toString();
    } catch (e) {
      return "";
    }
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

// void _editAsset(BuildContext context, AssetModel asset) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => AddAssetScreen(assetToEdit: asset, isEdit: true),
//     ),
//   );
// }
