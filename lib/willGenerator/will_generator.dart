import 'dart:io';
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

  final List<String> _relationshipOptions = ['Son', 'Brother', 'Wife', 'Other'];
  final List<String?> _selectedRelationships = [null];
  final List<TextEditingController?> _customRelationshipControllers = [null];

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

Map<String, pw.Widget Function(pw.Context)> get templates {
  String getRelationship(int i) {
    if (_selectedRelationships[i] == 'Other') {
      final custom = _customRelationshipControllers[i]?.text.trim() ?? '';
      return custom.isNotEmpty ? custom : 'Other';
    }
    return _selectedRelationships[i] ?? '';
  }

  return {
    'Original Will': (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            "LAST WILL AND TESTAMENT",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 30),
        pw.Text(
          "I, ${nameController.text.trim()}, residing at ${addressController.text.trim()}, being of sound mind and memory, and not acting under duress or undue influence, do hereby declare this to be my Last Will and Testament, and I revoke any and all wills and codicils heretofore made by me.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "ARTICLE I: PERSONAL INFORMATION",
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          "1.1 I am ${nameController.text.trim()}, of ${addressController.text.trim()}, and this Will is made on ${dateController.text.trim()}.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "ARTICLE II: BEQUESTS AND DEVISES",
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        for (int i = 0; i < propertyControllers.length; i++)
          pw.Text(
            "2.${i + 1} I give, devise, and bequeath ${propertyControllers[i].text.trim()} to ${beneficiaryControllers[i].text.trim()} (${getRelationship(i)}).",
            style: pw.TextStyle(fontSize: 12),
          ),
        pw.SizedBox(height: 20),
        pw.Text(
          "ARTICLE III: APPOINTMENT OF EXECUTOR",
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          "3.1 I appoint ${executorController.text.trim()} as the Executor of this Will, to serve without bond, to manage and distribute my estate according to the terms herein.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        if (guardianController.text.trim().isNotEmpty) ...[
          pw.Text(
            "ARTICLE IV: APPOINTMENT OF GUARDIAN",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "4.1 I appoint ${guardianController.text.trim()} as the Guardian of any minor children, should the need arise.",
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
        ],
        pw.Text(
          "IN WITNESS WHEREOF, I have hereunto set my hand and seal on this ${dateController.text.trim()} day.",
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              "___________________________",
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              "${nameController.text.trim()} (Testator)",
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "SIGNED, SEALED, PUBLISHED, AND DECLARED by the above-named Testator as and for his/her Last Will and Testament, in our presence, who, at his/her request, in his/her presence, and in the presence of each other, have hereunto subscribed our names as witnesses.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "___________________________",
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  "Witness 1 Signature",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Address: _______________",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Date: ${dateController.text.trim()}",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "___________________________",
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  "Witness 2 Signature",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Address: _______________",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Date: ${dateController.text.trim()}",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    'Simple Will': (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            "LAST WILL AND TESTAMENT",
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "I, ${nameController.text.trim()}, of ${addressController.text.trim()}, being of sound mind and body, do hereby declare this to be my Last Will and Testament, made on ${dateController.text.trim()}.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "I give my property as follows:",
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        for (int i = 0; i < propertyControllers.length; i++)
          pw.Text(
            "${propertyControllers[i].text.trim()} to ${beneficiaryControllers[i].text.trim()} (${getRelationship(i)}).",
            style: pw.TextStyle(fontSize: 12),
          ),
        pw.SizedBox(height: 20),
        pw.Text(
          "I appoint ${executorController.text.trim()} as the Executor of this Will.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "IN WITNESS WHEREOF, I have signed this Will on the date mentioned above.",
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "___________________________",
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              "___________________________",
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Signature of Testator", style: pw.TextStyle(fontSize: 10)),
            pw.Text("Signature of Witness", style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    ),
  };
}

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
        duration: const Duration(milliseconds: 800), 
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
        duration: const Duration(milliseconds: 800), 
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "❌ Error generating document: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.failedColor,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 800), 
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
    _selectedRelationships.clear();
    _customRelationshipControllers.clear();

    propertyControllers.add(TextEditingController());
    beneficiaryControllers.add(TextEditingController());
    _selectedRelationships.add(null);
    _customRelationshipControllers.add(null);
  }

  // void _addProperty() {
  //   setState(() {
  //     propertyControllers.add(TextEditingController());
  //     beneficiaryControllers.add(TextEditingController());
  //     _selectedRelationships.add(null);
  //     _customRelationshipControllers.add(null);
  //   });
  // }

  void _removeProperty(int index) {
    setState(() {
      if (propertyControllers.length > 1) {
        propertyControllers[index].dispose();
        propertyControllers.removeAt(index);
        beneficiaryControllers[index].dispose();
        beneficiaryControllers.removeAt(index);
        _selectedRelationships.removeAt(index);
        _customRelationshipControllers.removeAt(index);
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
    for (var controller in _customRelationshipControllers) {
      controller?.dispose();
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
                                _textField(
                                  propertyControllers[index],
                                  "Describe property",
                                ),
                                SizedBox(height: 10),
                                _textField(
                                  beneficiaryControllers[index],
                                  "Enter beneficiary name",
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedRelationships[index],
                                  decoration: _inputDecoration(
                                    context,
                                    "Select the relationship",
                                  ),
                                  items:
                                      _relationshipOptions
                                          .map(
                                            (rel) => DropdownMenuItem(
                                              value: rel,
                                              child: Text(rel),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedRelationships[index] = val;
                                      if (val == 'Other') {
                                        _customRelationshipControllers[index] =
                                            TextEditingController();
                                      } else {
                                        _customRelationshipControllers[index] =
                                            null;
                                        if (val == 'Other') {
                                          _customRelationshipControllers[index] =
                                              TextEditingController();
                                        } else {
                                          _customRelationshipControllers[index] =
                                              null;
                                        }
                                      }
                                    });
                                  },
                                ),
                                if (_selectedRelationships[index] ==
                                    'Other') ...[
                                  const SizedBox(height: 10),
                                  _textField(
                                    _customRelationshipControllers[index]!,
                                    "Enter custom relationship",
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      _label("Executor Name"),
                      _textField(executorController, "Enter executor name"),

                      _label("Guardian Name (optional)"),
                      _textField(
                        guardianController,
                        "Enter guardian name (if any)",
                        validator: (val) => null,
                      ),

                      const SizedBox(height: 20),
                      _label("Select Template"),
                      DropdownButtonFormField<String>(
                        value: selectedTemplate,
                        items:
                            templates.keys
                                .map(
                                  (template) => DropdownMenuItem(
                                    value: template,
                                    child: Text(template),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedTemplate = val;
                          });
                        },
                        decoration: _inputDecoration(
                          context,
                          "Choose template",
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _generatePdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Generate Will"),
                      ),

                      if (generatedFiles.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _label("Generated Wills"),
                        SizedBox(
                          height:
                              200, // scrollable area ki height fix kar rahe hain
                          child: ListView.builder(
                            itemCount: generatedFiles.length,
                            itemBuilder: (context, index) {
                              final path = generatedFiles[index];
                              final fileName = path.split('/').last;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Text(
                                    "•",
                                    style: TextStyle(fontSize: 22),
                                  ), // bullet
                                  title: Text(fileName),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                          setState(() {
                                            generatedFiles.removeAt(index);
                                          });
                                          Get.snackbar(
                                            "Deleted",
                                            "🗑️ Will deleted successfully",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor:
                                                context.failedColor,
                                            colorText: Colors.white,
                                            duration: const Duration(milliseconds: 800), 
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
