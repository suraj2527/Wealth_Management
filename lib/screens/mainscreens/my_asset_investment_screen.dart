import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/asset_controller.dart';
import 'package:wealth_app/controllers/filter_controller.dart';
import 'package:wealth_app/models/asset_model.dart';
import 'package:wealth_app/screens/subscreens/add_asset_screen.dart';
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

  final userId = Get.find<AuthController>().userId.value;
  final AssetController assetController = Get.put(AssetController());
  final FilterController filterController = Get.find<FilterController>();

  final String apiUrl = 'http://localhost:7173/api/asset';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/user/$userId'));
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        final assets = decoded.map((e) => AssetModel.fromJson(e)).toList();
        assetController.setAssets(assets);
        filterController.setAssetData(assets);
      } else {
        throw Exception('Failed to fetch assets');
      }
    } catch (e) {
      debugPrint("❌ Error fetching assets: $e");
    }
  }

  Future<void> _navigateToAddAsset() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAssetScreen()),
    );

    if (result is AssetModel) {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(result.toJson()..addAll({'userId': userId})),
      );
      await _fetchData();
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
              final assets = filterController.filteredAssetList;
              final totalAmount = assets
                  .where((a) => a.year == currentYear)
                  .fold<double>(
                    0.0,
                    (sum, a) => sum + (double.tryParse(a.amount) ?? 0.0),
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
                  _buildAssetList(assets, mediaWidth),
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
              "My Assets &",
              style: TextStyle(fontSize: 22, fontWeight: AppTextStyle.bold),
            ),
            Text(
              "Investments",
              style: TextStyle(fontSize: 22, fontWeight: AppTextStyle.bold),
            ),
            SizedBox(height: 4),
            Text(
              "Your Overall Assets Summary",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 40),
            Text(
              "Current Year Investments",
              style: TextStyle(fontWeight: AppTextStyle.semiBold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              "This Year Investments",
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
                onPressed: _navigateToAddAsset,
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
                  "Add Investment",
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
          "Assets List",
          style: TextStyle(fontWeight: AppTextStyle.semiBold, fontSize: 18),
        ),
        InkWell(
          onTap: () => _showFilterBottomSheet(context),
          child: Row(
            children: [
              Text(
                'Asset Filter',
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
      context: context,
      // isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Obx(() {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    FilterType.values.map((type) {
                      final selected =
                          filterController.assetFilterType.value == type;
                      return ListTile(
                        leading: Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color: selected ? Colors.deepPurple : Colors.grey,
                        ),
                        title: Text(
                          filterController.getFilterLabel(type),
                          style: TextStyle(
                            color: selected ? Colors.deepPurple : Colors.black,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          filterController.updateAssetFilter(type);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
              ),
            );
          }),
        );
      },
    );
  }

  // void _showFilterBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  //     builder: (_) {
  //       return Obx(() {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: FilterType.values.map((type) {
  //             final selected = filterController.assetFilterType.value == type;
  //             return ListTile(
  //               leading: Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? Colors.deepPurple : Colors.grey),
  //               title: Text(filterController.getFilterLabel(type)),
  //               onTap: () {
  //                 filterController.updateAssetFilter(type);
  //                 Navigator.pop(context);
  //               },
  //             );
  //           }).toList(),
  //         );
  //       });
  //     },
  //   );
  // }

  Widget _buildAssetList(List<AssetModel> assets, double mediaWidth) {
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
                assets.isEmpty
                    ? const Center(child: Text("No asset added yet"))
                    : ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
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
                                'assets/icons/asset_icon.svg',
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  isSelected ? Colors.white : Colors.deepPurple,
                                  BlendMode.srcIn,
                                ),
                              ),
                              title: Text(
                                "${asset.category} (${asset.year})",
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
                                asset.fundName,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                              trailing: Text(
                                "₹${asset.amount}",
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
