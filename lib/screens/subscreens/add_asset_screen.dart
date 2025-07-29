import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/widgets/calendar_input_field.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';

import '../../models/asset_model.dart';
import '../../controllers/asset_controller.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _fundNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _customSubCategoryController = TextEditingController();

  final List<String> _categories = [
    'Mutual funds',
    'Fixed Deposit',
    'Gold',
    'Others',
  ];

  final List<String> _subCategories = [
    'Equity Mutual fund',
    'Debt Fund',
    'ETF',
    'Others',
  ];

  String _selectedCategory = 'Mutual funds';
  String _selectedSubCategory = 'Equity Mutual fund';

  final ScrollController _scrollController = ScrollController();

  final String apiUrl = 'http://localhost:7173/api/asset';
  final userId = Get.find<AuthController>().userId.value;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitAsset() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final asset = AssetModel(
        year: DateTime.now().year.toString(),
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        category:
            _selectedCategory == 'Others'
                ? _customCategoryController.text.trim()
                : _selectedCategory,
        subCategory:
            _selectedSubCategory == 'Others'
                ? _customSubCategoryController.text.trim()
                : _selectedSubCategory,
        fundName: _fundNameController.text.trim(),
        amount: _amountController.text.trim(),
      );

      final assetController = Get.find<AssetController>();

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await assetController.submitAssetToServer(userId, asset);

      Get.back();

      if (result['success']) {
        Get.back();
        Get.snackbar(
          'Success',
          'Asset added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.successColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to add asset.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.failedColor,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.borderColor),
    );

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: context.fieldColor,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: focusedBorder,
        ),
      ),
      child: UniversalScaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Add Asset",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.buttonColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Back"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          CalendarInputField(
                            label: "Enter Start Date",
                            controller: _startDateController,
                          ),
                          const SizedBox(height: 16),

                          CalendarInputField(
                            label: "Enter End Date",
                            controller: _endDateController,
                          ),
                          const SizedBox(height: 16),

                          _label("Investment Category"),
                          _dropdownField(_categories, _selectedCategory, (val) {
                            setState(() {
                              _selectedCategory = val!;
                              if (_selectedCategory != 'Others') {
                                _customCategoryController.clear();
                              } else {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position
                                          .maxScrollExtent,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                );
                              }
                            });
                          }, context),
                          if (_selectedCategory == 'Others') ...[
                            const SizedBox(height: 10),
                            _textField(
                              _customCategoryController,
                              "Enter custom category",
                            ),
                          ],
                          const SizedBox(height: 16),

                          _label("Investment Sub-Category"),
                          _dropdownField(_subCategories, _selectedSubCategory, (
                            val,
                          ) {
                            setState(() {
                              _selectedSubCategory = val!;
                              if (_selectedSubCategory != 'Others') {
                                _customSubCategoryController.clear();
                              } else {
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position
                                          .maxScrollExtent,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                );
                              }
                            });
                          }, context),
                          if (_selectedSubCategory == 'Others') ...[
                            const SizedBox(height: 10),
                            _textField(
                              _customSubCategoryController,
                              "Enter custom sub-category",
                            ),
                          ],
                          const SizedBox(height: 16),

                          _label("Investment Fund Name"),
                          _textField(_fundNameController, "Enter Fund Name"),
                          const SizedBox(height: 16),

                          _label("Enter Amount"),
                          _textField(
                            _amountController,
                            "Enter Amount",
                            isNumber: true,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitAsset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _dropdownField(
    List<String> items,
    String? currentValue,
    void Function(String?) onChanged,
    BuildContext context,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField2<String>(
      value: currentValue,
      isExpanded: true,
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode ? context.mainFontColor : Colors.black,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: -4, vertical: 16),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        elevation: 3,
        decoration: BoxDecoration(
          color: context.fieldColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
      ),
      items:
          items
              .map(
                (val) => DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: TextStyle(
                      color: isDarkMode ? context.mainFontColor : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }
}
