import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/presentation/widgets/calendar_input_field.dart';
import 'package:wealth_app/presentation/widgets/dot_loader.dart';
import 'package:wealth_app/presentation/widgets/network_widget.dart';
import 'package:wealth_app/presentation/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';

import '../../../models/asset_model.dart';
import '../../../controllers/asset_controller.dart';

class AddAssetScreen extends StatefulWidget {
  final AssetModel? assetToEdit;
  final bool isEdit;

  const AddAssetScreen({super.key, this.assetToEdit, this.isEdit = false});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _fundNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _customSubCategoryController =
      TextEditingController();

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

  String? _selectedCategory ;
  String? _selectedSubCategory ;

  final ScrollController _scrollController = ScrollController();
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = Get.find<AuthController>().dbUserId.value;

    if (widget.isEdit && widget.assetToEdit != null) {
      final asset = widget.assetToEdit!;
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      _startDateController.text = asset.startDate;
      _endDateController.text = asset.endDate;
      _startDateController.text = formatter.format(
        DateTime.parse(asset.startDate),
      );
      _endDateController.text = formatter.format(DateTime.parse(asset.endDate));
      _fundNameController.text = asset.investmentFundName;
      _amountController.text = asset.amount.toString();

      if (_categories.contains(asset.investmentCategory)) {
        _selectedCategory = asset.investmentCategory;
      } else {
        _selectedCategory = 'Others';
        _customCategoryController.text = asset.investmentCategory;
      }

      if (_subCategories.contains(asset.investmentSubCategory)) {
        _selectedSubCategory = asset.investmentSubCategory;
      } else {
        _selectedSubCategory = 'Others';
        _customSubCategoryController.text = asset.investmentSubCategory;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitAsset() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (userId == null || userId.isEmpty) {
      return _showError("User not authenticated");
    }

    try {
      final asset = AssetModel(
        userId: userId,
        id: '',
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        investmentCategory:
            _selectedCategory == 'Others'
                ? _customCategoryController.text.trim()
                : _selectedCategory!,
        investmentSubCategory:
            _selectedSubCategory == 'Others'
                ? _customSubCategoryController.text.trim()
                : _selectedSubCategory!,
        investmentFundName: _fundNameController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      );

      final assetController = Get.find<AssetController>();

      Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);

      late Map<String, dynamic> result;
      if (widget.isEdit) {
        result = await assetController.updateAsset(userId, asset);
      } else {
        result = await assetController.submitAssetAndRefresh(userId, asset);
      }
      if (Get.isDialogOpen ?? false) Get.back();

      if (result['success'] == true) {
        await assetController.fetchAssets(userId);

        Get.snackbar(
          'Success',
          widget.isEdit
              ? 'Asset updated successfully'
              : 'Asset added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.successColor,
          colorText: Colors.white,
        );
        Get.back();
        Get.offNamed('/assets');
      } else {
        _showError(result['message'] ?? 'Something went wrong');
        if (Get.isDialogOpen ?? false) Get.back();
      }
    } catch (e) {
      debugPrint('submitAsset error: $e');
      _showError("Something went wrong");
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: context.failedColor,
      colorText: Colors.white,
    );
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
      child: NetworkAwareWidget(
        child: UniversalScaffold(
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
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
                                Text(
                                  widget.isEdit ? "Edit Asset" : "Add Asset",
                                  style: const TextStyle(
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
                            _dropdownField(_categories, _selectedCategory, (
                              val,
                            ) {
                              setState(() {
                                _selectedCategory = val!;
                                if (_selectedCategory != 'Others') {
                                  _customCategoryController.clear();
                                }
                              });
                            }, context,
                            hint: "Select Investment Category"
                            ),
                            if (_selectedCategory == 'Others') ...[
                              const SizedBox(height: 10),
                              _textField(
                                _customCategoryController,
                                "Enter custom category",
                              ),
                            ],
                            const SizedBox(height: 16),

                            _label("Investment Sub-Category"),
                            _dropdownField(
                              _subCategories,
                              _selectedSubCategory,
                              (val) {
                                setState(() {
                                  _selectedSubCategory = val!;
                                  if (_selectedSubCategory != 'Others') {
                                    _customSubCategoryController.clear();
                                  }
                                });
                              },
                              context,
                              hint: "Enter Sub Category"
                            ),
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
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return "Required";
                                }
                                final number = double.tryParse(val.trim());
                                if (number == null) {
                                  return "Enter a valid number";
                                }
                                if (number < 0) {
                                  return "Amount can't be negative";
                                }
                                return null;
                              },
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
                        child: Text(
                          widget.isEdit ? "Update" : "Submit",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator:
          validator ??
          (val) {
            if (val == null || val.trim().isEmpty) return "Required";
            if (isNumber) {
              final number = double.tryParse(val.trim());
              if (number == null) return "Enter a valid number";
              if (number <= 0) return "Amount must be greater than 0";
            }
            return null;
          },
      decoration: _inputDecoration(context, hint),
    );
  }

  Widget _dropdownField(
  List<String> items,
  String? currentValue,
  void Function(String?) onChanged,
  BuildContext context,
  {String hint = ""} 
) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return DropdownButtonFormField2<String>(
    value: currentValue,
    isExpanded: true,
    hint: Text(
      hint,
      style: TextStyle(
        fontSize: 16,
        color: context.hintColor,
      ),
    ),
    style: TextStyle(
      fontSize: 16,
      color: isDarkMode ? context.mainFontColor : Colors.black,
    ),
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: -4, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.borderColor, width: 1.2),
      ),
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
    items: items
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

InputDecoration _inputDecoration(BuildContext context, String hint) {
  return InputDecoration(
    filled: true,
    fillColor: context.fieldColor,
    hintText: hint,
    hintStyle:  TextStyle(color: context.hintColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.borderColor),
    ),
  );
}
}