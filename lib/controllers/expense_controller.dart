import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  var expenseList = <ExpenseModel>[].obs;
  final String baseUrl = 'http://localhost:7173/api/expense';

  Future<Map<String, dynamic>> fetchExpenses(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        expenseList.value = data.map((e) => ExpenseModel.fromJson(e)).toList();
        return {'success': true};
      } else {
        debugPrint('Failed to fetch expenses. Status: ${response.statusCode}');
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Exception: $e'};
    }
  }

  void addExpense(ExpenseModel expense) {
    expenseList.add(expense);
  }

  void removeExpense(int index) {
    if (index >= 0 && index < expenseList.length) {
      expenseList.removeAt(index);
    }
  }

  void clearExpenses() {
    expenseList.clear();
  }

  Future<Map<String, dynamic>> submitExpenseAndRefresh(
    String userId,
    ExpenseModel expense,
  ) async {
    final fullExpenseJson = expense.toJson()..addAll({'userId': userId});
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fullExpenseJson),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchExpenses(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to add expense (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }
}
