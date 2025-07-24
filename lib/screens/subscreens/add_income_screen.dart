import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/constants/font_sizes.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/controllers/income_controller.dart';
import 'package:wealth_app/models/income_model.dart';
import 'package:wealth_app/widgets/income_graph.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

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

  final List<String> _types = ['Monthly', 'Yearly', 'Annual', 'OneTime'];
  final List<String> _incomeCategories = [
    'Salary',
    'Rent',
    'Business',
    'Capital Gain',
    'Other',
  ];

final userId = Get.find<AuthController>().userId.value;

  Future<void> _submitIncome() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIncomeCategory == null) {
      Get.snackbar(
        'Error',
        'Please select an income source',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.failedcolor,
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
        backgroundColor: AppColors.failedcolor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final incomeModel = IncomeModel(
        title: _sourceController.text.trim(),
        year: DateTime.now().year.toString(),
        amount: amountValue,
        source: _sourceController.text.trim(),
        type: _selectedType,
        date: DateTime.now().toIso8601String(),
        category: _selectedIncomeCategory!,
        userId: userId,
      );

      final result = await incomeController.addIncome(incomeModel);

      if (result['success'] == true) {
        _formKey.currentState?.reset();
        _sourceController.clear();
        _amountController.clear();
        _selectedType = 'Monthly';
        _selectedIncomeCategory = null;

        await Future.wait([
          incomeController.fetchIncomes(userId),
          incomeController.fetchTotalIncome(userId),
        ]);

        Get.snackbar(
          'Success',
          'Income added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successcolor,
          colorText: Colors.white,
        );

        if (mounted) Navigator.pop(context);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to add income',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.failedcolor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('submitIncome error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.failedcolor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;
    final mediaWidth = MediaQuery.of(context).size.width;

    return UniversalScaffold(
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
                  // Header Row
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
                          backgroundColor: AppColors.buttonColor,
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

                  // Source dropdown
                  _label("Source"),
                  const SizedBox(height: 6),
                  DropdownButtonFormField2<String>(
                    value: _selectedIncomeCategory,
                    isExpanded: true,
                    decoration: _inputDecoration("Select income source"),
                    items:
                        _incomeCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
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
                        (val) => val == null || val.isEmpty ? "Required" : null,
                  ),

                  if (_selectedIncomeCategory == 'Other') ...[
                    const SizedBox(height: 12),
                    _textField(_sourceController, "Enter custom source"),
                  ],

                  const SizedBox(height: 16),
                  _label("Amount"),
                  const SizedBox(height: 6),
                  _textField(_amountController, "Enter amount", isNumber: true),

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
                                    label: Text(
                                      type,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    avatar: null,
                                    selected: isSelected,
                                    selectedColor: AppColors.buttonColor,
                                    backgroundColor: AppColors.fieldcolor,
                                    onSelected:
                                        (_) => setState(
                                          () => _selectedType = type,
                                        ),
                                    // materialTapTargetSize: MaterialTapTargetSize.padded
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitIncome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
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
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Income Graph",
                      style: TextStyle(
                        fontSize: FontSizes.heading1,
                        fontWeight: AppTextStyle.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: mediaHeight * 0.23,
                    child: const IncomeGraph(),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      
      fillColor: AppColors.fieldcolor,
      hintText: hint,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.bordercolor.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.bordercolor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.bordercolor),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {

    bool isNumber = false,
    
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
          decoration: _inputDecoration(hint),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
