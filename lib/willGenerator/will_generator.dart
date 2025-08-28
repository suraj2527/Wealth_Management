import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:wealth_app/presentation/widgets/calendar_input_field.dart';
import 'package:wealth_app/presentation/widgets/universal_scaffold.dart';

class WillGeneratorPage extends StatefulWidget {
  const WillGeneratorPage({Key? key}) : super(key: key);

  @override
  _WillGeneratorPageState createState() => _WillGeneratorPageState();
}

class _WillGeneratorPageState extends State<WillGeneratorPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final dateController = TextEditingController(
    text: DateFormat('MMMM d, yyyy').format(DateTime.now()),
  ); 
  final executorController = TextEditingController();
  final guardianController = TextEditingController();
  String? generatedFilePath;
  String? selectedTemplate = 'Original Will';

  final List<TextEditingController> propertyControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> beneficiaryControllers = [
    TextEditingController(),
  ];

  Map<String, pw.Widget Function(pw.Context)> get templates => {
    'Original Will':
        (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Centered Title
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

            // Declaration
            pw.Text(
              "I, ${nameController.text.trim()}, residing at ${addressController.text.trim()}, being of sound mind and memory, and not acting under duress or undue influence, do hereby declare this to be my Last Will and Testament, and I revoke any and all wills and codicils heretofore made by me.",
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),

            // Article 1: Personal Information
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

            // Article 2: Bequests
            pw.Text(
              "ARTICLE II: BEQUESTS AND DEVISES",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            for (int i = 0; i < propertyControllers.length; i++)
              pw.Text(
                "2.${i + 1} I give, devise, and bequeath ${propertyControllers[i].text.trim()} to ${beneficiaryControllers[i].text.trim()}.",
                style: pw.TextStyle(fontSize: 12),
              ),
            pw.SizedBox(height: 20),

            // Article 3: Executor
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

            // Article 4: Guardian (Optional)
            if (guardianController.text.trim().isNotEmpty) ...[
              pw.Text(
                "ARTICLE IV: APPOINTMENT OF GUARDIAN",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "4.1 I appoint ${guardianController.text.trim()} as the Guardian of any minor children, should the need arise.",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
            ],

            // Signature and Witness Section
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
    'Simple Will':
        (context) => pw.Column(
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
                "${propertyControllers[i].text.trim()} to ${beneficiaryControllers[i].text.trim()}.",
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
                pw.Text(
                  "Signature of Testator",
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Signature of Witness",
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
  };

  Future<void> _generatePdf() async {
    if (!mounted) return;

    setState(() {
      generatedFilePath = null; 
    });

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
        generatedFilePath = file.path; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Will generated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error generating document: $e")),
      );
    }
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
    return UniversalScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  hintText: "Enter your full name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  hintText: "Enter your address",
                ),
              ),
              const SizedBox(height: 16),
              CalendarInputField(label: "Date", controller: dateController),
              const SizedBox(height: 16),
              ...List.generate(
                propertyControllers.length,
                (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: propertyControllers[index],
                      decoration: InputDecoration(
                        labelText: "Property ${index + 1} Description",
                        border: const OutlineInputBorder(),
                        hintText: "Describe property ${index + 1}",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeProperty(index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: beneficiaryControllers[index],
                      decoration: InputDecoration(
                        labelText: "Beneficiary ${index + 1} Name",
                        border: const OutlineInputBorder(),
                        hintText: "Enter beneficiary ${index + 1}'s name",
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _addProperty,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  "Add Property",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: executorController,
                decoration: const InputDecoration(
                  labelText: "Executor Name",
                  border: OutlineInputBorder(),
                  hintText: "Enter executor's name",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: guardianController,
                decoration: const InputDecoration(
                  labelText: "Guardian Name (Optional)",
                  border: OutlineInputBorder(),
                  hintText: "Enter guardian's name if applicable",
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedTemplate,
                hint: const Text("Select Template"),
                items:
                    templates.keys.map((String template) {
                      return DropdownMenuItem<String>(
                        value: template,
                        child: Text(template),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTemplate = newValue;
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _generatePdf,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text(
                  "Generate Will",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              if (generatedFilePath != null) ...[
                const SizedBox(height: 16),
                FileInfo(filePath: generatedFilePath!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FileInfo extends StatelessWidget {
  final String filePath;

  const FileInfo({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "File saved at: $filePath",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final result = await OpenFile.open(filePath);
            if (result.type != ResultType.done) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("❌ Failed to open file")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text(
            "View File",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
