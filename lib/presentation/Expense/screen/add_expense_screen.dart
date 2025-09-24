import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wealth_app/presentation/Authentication/controller/auth_controller.dart';
import 'package:wealth_app/utils/constants/text_styles.dart';
import 'package:wealth_app/widgets/calendar_input_field.dart';
import 'package:wealth_app/widgets/dot_loader.dart';
import 'package:wealth_app/presentation/screens/Network/network_widget.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import '../model/expense_model.dart';
import '../controller/expense_controller.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? assetToEdit;
  final bool isEdit;

  const AddExpenseScreen({super.key, this.assetToEdit, this.isEdit = false});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _incrementPercentageController =
      TextEditingController();
  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _customSubCategoryController =
      TextEditingController();

  final List<String> _expenseTypes = [
    'Housing',
    'Food',
    'Transport',
    'Healthcare',
    'Other',
  ];
  final List<String> _subCategories = [
    'Property taxes',
    'Rent',
    'Maintenance',
    'Other',
  ];
  final List<String> _periods = ['Monthly', 'Yearly'];
  final List<String> _natureTypes = ['Fixed', 'Variable'];

  String? _selectedType;
  String? _selectedSubCategory ;
  String? _selectedPeriod ;
  String? _selectedNature ;
  bool _isRecurring = false;

  final userId = Get.find<AuthController>().dbUserId.value;
  final ExpenseController expenseController = Get.find<ExpenseController>();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.assetToEdit != null) {
      final expense = widget.assetToEdit!;
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      _startDateController.text = formatter.format(
        DateTime.parse(expense.startDate),
      );
      _yearController.text = expense.year.toString();
      _amountController.text = expense.amount.toString();
      _incrementPercentageController.text =
          expense.expectedAnnualIncrementPercentage.toString();

      _isRecurring = expense.isRecurring;

      _selectedType =
          _expenseTypes.contains(expense.expenseType)
              ? expense.expenseType
              : 'Other';
      if (_selectedType == 'Other') {
        _customTypeController.text = expense.expenseType;
      }

      _selectedSubCategory =
          _subCategories.contains(expense.subCategory)
              ? expense.subCategory
              : 'Other';
      if (_selectedSubCategory == 'Other') {
        _customSubCategoryController.text = expense.subCategory;
      }

      _selectedPeriod =
          _periods.contains(expense.period) ? expense.period : _periods[0];
      _selectedNature =
          _natureTypes.contains(expense.natureType)
              ? expense.natureType
              : _natureTypes[0];
    }
  }

  Future<void> _submitExpense() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final parsedStartDate = DateTime.tryParse(
        _startDateController.text.trim(),
      );

      if (parsedStartDate == null) {
        Get.snackbar(
          "Error",
          "Invalid start date format",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.failedColor,
          colorText: Colors.white,
        );
        return;
      }

      try {
        final expense = ExpenseModel(
          userId: userId,
          Id: widget.isEdit ? widget.assetToEdit!.Id : '',
        
          year:
              int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
          expenseType:
              _selectedType == 'Other'
                  ? _customTypeController.text.trim()
                  : _selectedType!,
          subCategory:
              _selectedSubCategory == 'Other'
                  ? _customSubCategoryController.text.trim()
                  : _selectedSubCategory!,
          period: _selectedPeriod!,
          natureType: _selectedNature!,
          amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
          expectedAnnualIncrementPercentage:
              double.tryParse(_incrementPercentageController.text.trim()) ??
              0.0,
          startDate: _startDateController.text,
          isRecurring: _isRecurring,
        );

        Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);
        late Map<String, dynamic> result;
        if (widget.isEdit) {
          result = await expenseController.updateExpense(userId, expense);
        } else {
          result = await expenseController.submitExpenseAndRefresh(
            userId,
            expense,
          );
        }
        if (Get.isDialogOpen ?? false) Get.back();

        if (result['success']) {
          Get.snackbar(
            "Success",
            widget.isEdit
                ? "Expense updated successfully!"
                : "Expense added successfully!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: context.successColor,
            colorText: Colors.white,
          );
          Get.back();
          Get.offNamed('/expenses');
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
    final mediaHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: context.fieldColor,
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
            borderSide: BorderSide(color: context.buttonColor),
          ),
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
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [..._formFields(context)],
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
                      height: mediaHeight * 0.055,
                      child: ElevatedButton(
                        onPressed: _submitExpense,
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

  List<Widget> _formFields(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isEdit ? "Edit Expense" : "Add Expense",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.mainFontColor,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Back"),
          ),
        ],
      ),
      SizedBox(height: mediaHeight * 0.02),
      _label("Year"),
      _textField(_yearController, "Enter year", isNumber: true),
      SizedBox(height: mediaHeight * 0.015),
      _label("Expense Type"),
      _dropdownField(
        _expenseTypes,
        _selectedType,
        (val) => setState(() => _selectedType = val),
        context,
        hint: "Select Expense Type"
      ),
      if (_selectedType == 'Other') ...[
        SizedBox(height: mediaHeight * 0.01),
        _textField(_customTypeController, "Enter custom expense type"),
      ],
      SizedBox(height: mediaHeight * 0.015),
      _label("Sub-Category"),
      _dropdownField(
        _subCategories,
        _selectedSubCategory,
        (val) => setState(() => _selectedSubCategory = val),
        context,
        hint: "Select Sub Category"
      ),
      if (_selectedSubCategory == 'Other') ...[
        SizedBox(height: mediaHeight * 0.01),
        _textField(_customSubCategoryController, "Enter custom sub-category"),
      ],
      SizedBox(height: mediaHeight * 0.015),
      _label("Period"),
      _dropdownField(
        _periods,
        _selectedPeriod,
        (val) => setState(() => _selectedPeriod = val),
        context,
        hint: "Select Period"
      ),
      SizedBox(height: mediaHeight * 0.015),
      _label("Nature Type"),
      _dropdownField(
        _natureTypes,
        _selectedNature,
        (val) => setState(() => _selectedNature = val),
        context,
        hint: "Select Nature"
      ),
      SizedBox(height: mediaHeight * 0.015),
      _label("Amount"),
      _textField(_amountController, "Enter amount", isNumber: true),
      SizedBox(height: mediaHeight * 0.015),
      _label("Expected Annual Increment %"),
      _textField(
        _incrementPercentageController,
        "Enter increment %",
        isNumber: true,
        validator: (val) {
          if (val == null || val.trim().isEmpty) return "Required";
          final number = double.tryParse(val.trim());
          if (number == null) return "Enter a valid number";
          if (number < 0) return "Increment % can't be negative";
          return null;
        },
      ),
      SizedBox(height: mediaHeight * 0.015),
      CalendarInputField(
        label: "Enter Start Date",
        controller: _startDateController,
      ),
      SizedBox(height: mediaHeight * 0.015),
      CheckboxListTile(
        title: const Text("Is Recurring"),
        value: _isRecurring,
        onChanged: (val) => setState(() => _isRecurring = val ?? false),
      ),
      SizedBox(height: mediaHeight * 0.03),
    ];
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: AppTextStyle.bold));
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