import 'dart:io';
import 'package:excel/excel.dart' as xls;
import 'package:flutter/material.dart';

class ExcelViewerScreen extends StatelessWidget {
  final File file;

  const ExcelViewerScreen({super.key, required this.file});

  List<List<String>> readExcel(File file) {
    final bytes = file.readAsBytesSync();
    final excel = xls.Excel.decodeBytes(bytes);

    final List<List<String>> rows = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        rows.add(row.map((cell) => cell?.value.toString() ?? "").toList());
      }
      break;
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = readExcel(file);

    return Scaffold(
      appBar: AppBar(
        title: Text(file.path.split("/").last),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final row = rows[i];
            final isHeader = i == 0;

            return Container(
              decoration: BoxDecoration(
                color: isHeader ? Colors.green.shade100 : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  children:
                      row.map((cell) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color:
                                isHeader ? Colors.green.shade50 : Colors.white,
                          ),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 4),
                          constraints: const BoxConstraints(minWidth: 100),
                          child: Text(
                            cell,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isHeader
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            );
          },
          shrinkWrap: true,
        ),
      ),
    );
  }
}
