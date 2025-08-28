import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:wealth_app/extension/theme_extension.dart';
import 'package:wealth_app/presentation/widgets/calendar_input_field.dart';
import 'package:wealth_app/presentation/widgets/universal_scaffold.dart';

class WillGeneratorPage extends StatefulWidget {
  const WillGeneratorPage({Key? key}) : super(key: key);

  @override
  _WillGeneratorPageState createState() => _WillGeneratorPageState();
}

class _WillGeneratorPageState extends State<WillGeneratorPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final dateController = TextEditingController(
    text: DateFormat('MMMM d, yyyy').format(DateTime.now()),
  );
  final executorController = TextEditingController();
  final guardianController = TextEditingController();

  String? selectedTemplate = 'Original Will';
  final List<TextEditingController> propertyControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> beneficiaryControllers = [
    TextEditingController(),
  ];

  List<String> generatedFiles = [];

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: context.fieldColor,
      hintText: hint,
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
    );
  }
   final List<String> _relationship = [
    'Son',
    'Brother',
    'Wife',
    'Other',
  ];
  String _selectedrelationship = 'Son';

  Widget _textField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator:
          validator ??
          (val) {
            if (val == null || val.trim().isEmpty) return "Required";
            if (isNumber) {
              final number = double.tryParse(val.trim());
              if (number == null) return "Enter a valid number";
              if (number <= 0) return "Value must be greater than 0";
            }
            return null;
          },
      decoration: _inputDecoration(context, hint),
    );
  }


  Map<String, pw.Widget Function(pw.Context)> get templates => {
    'Original Will':
        (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                "LAST WILL AND TESTAMENT",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "I, ${nameController.text}, residing at ${addressController.text}, "
              "being of sound mind, do hereby declare this to be my Last Will and Testament.",
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              "ARTICLE I: REVOCATION OF PRIOR WILLS",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("I hereby revoke all prior Wills and Codicils made by me."),

            pw.SizedBox(height: 20),
            pw.Text(
              "ARTICLE II: APPOINTMENT OF EXECUTOR",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "I appoint ${executorController.text} as Executor of this Will.",
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "ARTICLE III: DISPOSITION OF PROPERTY",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("I give, devise, and bequeath my property as follows:"),
            ...List.generate(propertyControllers.length, (i) {
              return pw.Bullet(
                text:
                    "To ${beneficiaryControllers[i].text}, I give ${propertyControllers[i].text}.",
              );
            }),

            pw.SizedBox(height: 20),
            pw.Text(
              "ARTICLE IV: GUARDIANSHIP",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              guardianController.text.isNotEmpty
                  ? "I appoint ${guardianController.text} as Guardian of my minor children."
                  : "No guardian specified.",
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "ARTICLE V: GENERAL PROVISIONS",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "1. My Executor shall have full authority to settle my estate.\n"
              "2. All debts, expenses, and taxes shall be paid from my estate.",
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              "IN WITNESS WHEREOF, I have hereunto set my hand this ${dateController.text}.",
            ),
            pw.SizedBox(height: 40),
            pw.Text("Signature: __________________________"),
            pw.SizedBox(height: 20),
            pw.Text("Witness 1: __________________________"),
            pw.SizedBox(height: 10),
            pw.Text("Witness 2: __________________________"),
          ],
        ),

    'Simple Will':
        (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                "SIMPLE WILL",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "I, ${nameController.text}, declare this as my Will. "
              "I revoke all prior Wills.",
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              "Executor:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("I appoint ${executorController.text} as Executor."),

            pw.SizedBox(height: 20),
            pw.Text(
              "Beneficiaries:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...List.generate(propertyControllers.length, (i) {
              return pw.Bullet(
                text:
                    "${beneficiaryControllers[i].text} will receive ${propertyControllers[i].text}.",
              );
            }),

            pw.SizedBox(height: 20),
            pw.Text("Date: ${dateController.text}"),
            pw.SizedBox(height: 20),
            pw.Text("Signature: __________________________"),
            pw.SizedBox(height: 20),
            pw.Text("Witness: __________________________"),
          ],
        ),
  };

  Future<void> _generatePdf() async {
    FocusScope.of(context).unfocus();
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => templates[selectedTemplate]!(context),
        ),
      );

      final outputDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${outputDir.path}/will_generated_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        generatedFiles.add(file.path);
        _clearForm();
      });

      Get.snackbar(
        "Success",
        "✅ Will generated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "❌ Error generating document: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
      );
    }
  }

  void _clearForm() {
    nameController.clear();
    addressController.clear();
    dateController.text = DateFormat('MMMM d, yyyy').format(DateTime.now());
    executorController.clear();
    guardianController.clear();
    propertyControllers.clear();
    beneficiaryControllers.clear();
    propertyControllers.add(TextEditingController());
    beneficiaryControllers.add(TextEditingController());
  }

  void _addProperty() {
    setState(() {
      propertyControllers.add(TextEditingController());
      beneficiaryControllers.add(TextEditingController());
    });
  }

  void _removeProperty(int index) {
    setState(() {
      if (propertyControllers.length > 1) {
        propertyControllers[index].dispose();
        propertyControllers.removeAt(index);
        beneficiaryControllers[index].dispose();
        beneficiaryControllers.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    dateController.dispose();
    executorController.dispose();
    guardianController.dispose();
    for (var controller in propertyControllers) {
      controller.dispose();
    }
    for (var controller in beneficiaryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: context.borderColor.withOpacity(0.1)),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),

              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Will Generator",
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
                      SizedBox(height: 10),
                      _label("Full Name"),
                      _textField(nameController, "Enter your full name"),

                      _label("Address"),
                      _textField(
                        addressController,
                        "Enter your address",
                        maxLines: 2,
                      ),

                      CalendarInputField(
                        label: "Date",
                        controller: dateController,
                      ),

                      const SizedBox(height: 12),
                      _label("Property Details"),
                      ...List.generate(
                        propertyControllers.length,
                        (index) => Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Property ${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (propertyControllers.length > 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _removeProperty(index),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                // _label("Description"),
                                _textField(
                                  propertyControllers[index],
                                  "Describe property",
                                ),
                                SizedBox(height: 10),

                                // _label("Beneficiary Name"),
                                _textField(
                                  beneficiaryControllers[index],
                                  "Enter beneficiary name",
                                ),
                                const SizedBox(height: 10),
                     
                              ],
                            ),
                          ),
                        ),
                      ),

                      OutlinedButton.icon(
                        onPressed: _addProperty,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.buttonColor,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.add, color: context.buttonColor),
                        label: Text(
                          "Add More",
                          style: TextStyle(
                            color: context.buttonColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      _label("Executor Name"),
                      _textField(executorController, "Enter executor's name"),

                      _label("Guardian Name (Optional)"),
                      _textField(
                        guardianController,
                        "Enter guardian's name if applicable",
                        validator: (value) => null,
                      ),

                     
                      const SizedBox(height: 10),
                      _label("Select Template"),
                      _dropdownField(
                        templates.keys.toList(),
                        selectedTemplate,
                        (val) => setState(() => selectedTemplate = val),
                        context,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _generatePdf,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Generate Will",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (generatedFiles.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          "Generated Wills",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: generatedFiles.length,
                          itemBuilder: (context, index) {
                            final path = generatedFiles[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 8.0,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Will ${index + 1}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          path,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => OpenFile.open(path),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final file = File(path);
                                          if (await file.exists()) {
                                            await file.delete();
                                          }
                                          setState(
                                            () =>
                                                generatedFiles.removeAt(index),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
      fontSize: 15,
      color: isDarkMode ? context.mainFontColor : Colors.black,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: context.fieldColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        borderSide: BorderSide(color: context.borderColor),
      ),
    ),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 250,
      elevation: 3,
      decoration: BoxDecoration(
        color: context.fieldColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
    ),
    items:
        items
            .map(
              (val) => DropdownMenuItem<String>(value: val, child: Text(val)),
            )
            .toList(),
    onChanged: onChanged,
    validator: (val) => val == null || val.isEmpty ? "Required" : null,
  );
}
