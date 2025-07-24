import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wealth_app/constants/colors.dart';
import 'package:wealth_app/widgets/universal_scaffold.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  File? selectedFile;
  List<File> savedFiles = [];

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> saveSelectedFile() async {
    if (selectedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = selectedFile!.path.split('/').last;
    final newPath = '${directory.path}/$fileName';
    final newFile = await selectedFile!.copy(newPath);

    setState(() {
      savedFiles.add(newFile);
      selectedFile = null;
    });
  }

  void showDeleteConfirmation(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete File"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.mainFontColor),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                savedFiles.removeAt(index);
              });
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.05;
    final width = MediaQuery.of(context).size.width * 0.8;

    return UniversalScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upload document",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
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
            const SizedBox(height: 30),
            Text(
              "Download Sample Record",
              style: TextStyle(
                color: AppColors.mainFontColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.linecolor),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.fieldcolor,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "dynamic-monk-excel-sheet.xlsx",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/download_icon.svg',
                        height: 18,
                        width: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              dashPattern: const [6, 3],
              color: AppColors.linecolor,
              strokeWidth: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldcolor,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Import data from Excel",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedFile?.path.split("/").last ?? "No file selected",
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: pickExcelFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/upload_icon.svg',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            ElevatedButton(
              onPressed: selectedFile != null ? saveSelectedFile : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Save your Data",
                style: TextStyle(color: AppColors.buttonTextColor),
              ),
            ),

            const SizedBox(height: 20),

            if (savedFiles.isNotEmpty)
              const Text(
                "Saved Files:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

            if (savedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: savedFiles.length,
                  itemBuilder: (context, index) {
                    final file = savedFiles[index];
                    final fileName = file.path.split('/').last;

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () async {
                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          // await Get.to(() => ExcelViewerScreen(file: file));
                          Get.back();
                        },
                        child: Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.linecolor),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.fieldcolor,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Text(
                                "${index + 1}. ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: TextStyle(
                                    color: AppColors.mainFontColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.failedcolor,
                                ),
                                onPressed: () => showDeleteConfirmation(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
