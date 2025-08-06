import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wealth_app/constants/text_styles.dart';
import 'package:wealth_app/controllers/auth_controller.dart';
import 'package:wealth_app/widgets/dot_loader.dart';
// import 'package:wealth_app/widgets/dot_loader.dart';
import 'package:wealth_app/widgets/network_widget.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import '../../models/expense_model.dart';
import '../../controllers/expense_controller.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _startDateController = TextEditingController(
    text: DateTime.now().toIso8601String().substring(0, 10),
  );
  final TextEditingController _incrementPercentageController =
      TextEditingController(text: '0');

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

  String? _selectedType = 'Housing';
  String? _selectedSubCategory = 'Rent';
  String? _selectedPeriod = 'Monthly';
  String? _selectedNature = 'Fixed';

  final TextEditingController _customTypeController = TextEditingController();
  final TextEditingController _customSubCategoryController =
      TextEditingController();
  bool _isRecurring = false;

  final userId = Get.find<AuthController>().dbUserId.value;
  final ExpenseController expenseController = Get.find<ExpenseController>();

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

      final expense = ExpenseModel(
        userId: userId,
        year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
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
            double.tryParse(_incrementPercentageController.text.trim()) ?? 0.0,
        startDate:
            parsedStartDate != null ? parsedStartDate.toIso8601String() : '',
        isRecurring: _isRecurring,
        Id: '',
      );
      Get.dialog(const Center(child: DotLoader()), barrierDismissible: false);

      final result = await expenseController.submitExpenseAndRefresh(
        userId,
        expense,
      );

      if (result['success']) {
        _amountController.clear();
        _yearController.text = DateTime.now().year.toString();
        _startDateController.text = DateTime.now().toIso8601String().substring(
          0,
          10,
        );
        _incrementPercentageController.text = '0';

        setState(() {
          _selectedType = _expenseTypes[0];
          _selectedSubCategory = _subCategories[0];
          _selectedPeriod = _periods[0];
          _selectedNature = _natureTypes[0];
          _customTypeController.clear();
          _customSubCategoryController.clear();
          _isRecurring = false;
        });

        Get.snackbar(
          "Success",
          "Expense added successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.successColor,
          colorText: Colors.white,
        );
        Get.back();
        Get.toNamed('/expenses');
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Failed to add expense.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: context.failedColor,
          colorText: Colors.white,
        );
      }
    }
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
            "Add Expense",
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
      ),
      SizedBox(height: mediaHeight * 0.015),
      _label("Nature Type"),
      _dropdownField(
        _natureTypes,
        _selectedNature,
        (val) => setState(() => _selectedNature = val),
        context,
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
      ),
      SizedBox(height: mediaHeight * 0.015),
      _label("Start Date"),
      TextFormField(
        controller: _startDateController,
        validator: (val) {
          if (val == null || val.isEmpty) return "Required";
          if (DateTime.tryParse(val) == null) return "Invalid date format";
          return null;
        },
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            _startDateController.text = picked.toIso8601String().substring(
              0,
              10,
            );
          }
        },
        decoration: const InputDecoration(hintText: "Select start date"),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
