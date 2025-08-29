// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';

// class DocumentController extends GetxController {
//   Rx<File?> selectedFile = Rx<File?>(null);
//   RxList<File> savedFiles = <File>[].obs;

//   Future<void> pickExcelFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xlsx', 'xls'],
//     );

//     if (result != null && result.files.single.path != null) {
//       selectedFile.value = File(result.files.single.path!);
//     }
//   }

//   Future<void> saveSelectedFile() async {
//     if (selectedFile.value == null) return;

//     final directory = await getApplicationDocumentsDirectory();
//     final fileName = selectedFile.value!.path.split('/').last;
//     final newPath = '${directory.path}/$fileName';
//     final newFile = await selectedFile.value!.copy(newPath);

//     savedFiles.add(newFile);
//     selectedFile.value = null;
//   }

//   void deleteFile(int index) {
//     savedFiles.removeAt(index);
//   }
// }
