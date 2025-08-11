import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:wealth_app/presentation/controllers/auth_controller.dart';
import 'package:wealth_app/presentation/controllers/income_controller.dart';
import 'package:wealth_app/models/income_model.dart';
import 'package:wealth_app/presentation/widgets/calendar_input_field.dart';
import 'package:wealth_app/presentation/widgets/dot_loader.dart';
import 'package:wealth_app/presentation/widgets/network_widget.dart';
import 'package:wealth_app/presentation/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';

class AddIncomeScreen extends StatefulWidget {
  final IncomeModel? incomeToEdit;
  final bool isEdit;

  const AddIncomeScreen({super.key, this.incomeToEdit, this.isEdit = false});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final IncomeController incomeController = Get.find();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
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

  bool get isEdit => widget.incomeToEdit != null;

  @override
  void initState() {
    super.initState();
    dbUserId = Get.find<AuthController>().dbUserId.value;

    if (isEdit) {
      final income = widget.incomeToEdit!;

      final DateFormat formatter = DateFormat('yyyy-MM-dd');

      _sourceController.text = income.incomeType;
      _amountController.text = income.amount.toString();

      _startDateController.text = formatter.format(
        DateTime.parse(income.startDate),
      );
      _endDateController.text = formatter.format(
        DateTime.parse(income.endDate),
      );

      _selectedType = income.period;

      if (_incomeCategories.contains(income.incomeType)) {
        _selectedIncomeCategory = income.incomeType;
      } else {
        _selectedIncomeCategory = 'Other';
      }
    }
  }

  Future<void> _submitIncome() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedIncomeCategory == null) {
      return _showError("Please select an income source");
    }

    final amountValue = double.tryParse(_amountController.text.trim());
    if (amountValue == null || amountValue <= 0) {
      return _showError("Please enter a valid amount");
    }

    if (dbUserId == null) {
      return _showError("User not authenticated");
    }

    try {
      final incomeModel = IncomeModel(
        id: isEdit ? widget.incomeToEdit!.id : '',
        userId: dbUserId!,
        incomeType: _sourceController.text.trim(),
        amount: amountValue,
        period: _selectedType,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        expectedAnnualIncrementPercentage:
            widget.incomeToEdit?.expectedAnnualIncrementPercentage ?? 2.0,
        year: DateTime.now().year,
      );

      Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);
      Map<String, dynamic> result;
      if (isEdit) {
        result = await incomeController.updateIncome(incomeModel, dbUserId!);
      } else {
        result = await incomeController.addIncome(incomeModel);
      }
      if (Get.isDialogOpen ?? false) Get.back();

      if (result['success'] == true) {
        await incomeController.fetchIncomes(dbUserId!);
        Get.snackbar(
          "Success",
          isEdit
              ? "Income updated successfully!"
              : "Income added successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.successColor,
          colorText: Colors.white,
        );
        Get.back();
        Get.offNamed('/income');
      } else {
        _showError(result['message'] ?? "Something went wrong");
      }
    } catch (e) {
      debugPrint('submitIncome error: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      _showError("Something went wrong");
    }
  }

  void _showError(String msg) {
    if (Get.isDialogOpen ?? false) Get.back();
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
    final mediaHeight = MediaQuery.of(context).size.height;
    final mediaWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: context.fieldColor,
          border: _outlineBorder(context, false),
          enabledBorder: _outlineBorder(context, false),
          focusedBorder: _outlineBorder(context, true),
        ),
      ),
      child: NetworkAwareWidget(
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
                      _header(mediaWidth, mediaHeight),
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
                                      alignment: Alignment.centerLeft,
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
                      _periodChips(),
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
                          child: Text(
                            isEdit ? "Update" : "Submit",
                            style: const TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget _header(double mediaWidth, double mediaHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEdit ? "Edit Income" : "Add Income",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: context.fieldColor,
      hintText: hint,
      border: _outlineBorder(context, false),
      enabledBorder: _outlineBorder(context, false),
      focusedBorder: _outlineBorder(context, true),
    );
  }

  OutlineInputBorder _outlineBorder(BuildContext context, bool focused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color:
            focused
                ? context.borderColor
                : context.borderColor.withOpacity(0.1),
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
      validator: (val) {
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

  Widget _periodChips() {
    return SizedBox(
      height: 50,
      child: Row(
        children:
            _types.map((type) {
              final isSelected = _selectedType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ChoiceChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: context.borderColor),
                      label: Text(
                        type,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : (isSelected ? Colors.white : Colors.black),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: context.buttonColor,
                      backgroundColor: context.fieldColor,
                      onSelected: (_) => setState(() => _selectedType = type),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
