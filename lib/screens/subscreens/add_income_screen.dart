import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/models/income_model.dart';
import 'package:wealth_app/widgets/dot_loader.dart';
// import 'package:wealth_app/widgets/dot_loader.dart';
import 'package:wealth_app/widgets/network_widget.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final IncomeController incomeController = Get.find();

  String _selectedType = 'Monthly';
  String? _selectedIncomeCategory;
  String? dbUserId;

  final List<String> _types = ['Monthly', 'Yearly', 'Annual', 'OneTime'];
  final List<String> _incomeCategories = [
    'Salary',
    'Rent',
    'Business',
    'Capital Gain',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    dbUserId = Get.find<AuthController>().dbUserId.value;
  }

  Future<void> _submitIncome() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedIncomeCategory == null) {
      Get.snackbar(
        'Error',
        'Please select an income source',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
      return;
    }

    final amountValue = double.tryParse(_amountController.text.trim());
    if (amountValue == null || amountValue <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
      return;
    }

    if (dbUserId == null) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
      return;
    }
    // Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);

    try {
      final incomeModel = IncomeModel(
        userId: dbUserId!,
        incomeType: _sourceController.text.trim(),
        amount: amountValue,
        period: _selectedType,
        startDate: DateTime.now().toIso8601String(),
        expectedAnnualIncrementPercentage: 2.0,
        endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        year: DateTime.now().year,
        id: '',
      );
      Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);

      final result = await incomeController.addIncome(incomeModel);

      // if (Get.isDialogOpen ?? false) Get.back();

      if (result['success'] == true) {
        _formKey.currentState?.reset();
        _sourceController.clear();
        _amountController.clear();
        _selectedType = 'Monthly';
        _selectedIncomeCategory = null;

        await Future.wait([incomeController.fetchIncomes(dbUserId!)]);

        Get.snackbar(
          'Success',
          'Income added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.successColor,
          colorText: Colors.white,
        );
        Get.back();
        Get.toNamed('/income');
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to add income',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.failedColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('submitIncome error: $e');
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    final mediaWidth = MediaQuery.of(context).size.width;

    return NetworkAwareWidget(
      child: UniversalScaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: mediaHeight * 0.02,
                horizontal: mediaWidth * 0.05,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Income",
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
                            padding: EdgeInsets.symmetric(
                              horizontal: mediaWidth * 0.07,
                              vertical: mediaHeight * 0.012,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Back"),
                        ),
                      ],
                    ),
                    SizedBox(height: mediaHeight * 0.025),
                    _label("Source"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField2<String>(
                      value: _selectedIncomeCategory,
                      isExpanded: true,
                      decoration: _inputDecoration(
                        context,
                        "Select income source",
                      ),
                      items:
                          _incomeCategories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Align(
                                    alignment: Alignment(-1, 0),
                                    child: Text(category),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedIncomeCategory = val!;
                          if (val != 'Other') {
                            _sourceController.text = val;
                          } else {
                            _sourceController.clear();
                          }
                        });
                      },
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? "Required" : null,
                    ),
                    if (_selectedIncomeCategory == 'Other') ...[
                      const SizedBox(height: 12),
                      _textField(_sourceController, "Enter custom source"),
                    ],
                    const SizedBox(height: 16),
                    _label("Amount"),
                    const SizedBox(height: 6),
                    _textField(
                      _amountController,
                      "Enter amount",
                      isNumber: true,
                    ),
                    const SizedBox(height: 16),
                    _label("Period"),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children:
                            _types.map((type) {
                              final isSelected = _selectedType == type;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      side: BorderSide(
                                        color: context.borderColor,
                                      ),
                                      label: Text(
                                        type,
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : (isSelected
                                                      ? Colors.white
                                                      : Colors.black),
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: context.buttonColor,
                                      backgroundColor: context.fieldColor,
                                      onSelected:
                                          (_) => setState(() {
                                            _selectedType = type;
                                          }),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitIncome,
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
                    const SizedBox(height: 30),
                  ],
                ),
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

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: context.fieldColor,
      hintText: hint,

      // contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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

  Widget _textField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: _inputDecoration(context, hint),
    );
  }
}
