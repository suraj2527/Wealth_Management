import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../models/expense_model.dart';

class ExpenseController extends GetxController {
  var expenseList = <ExpenseModel>[].obs;
  final String baseUrl =
      'https://dynamicsmonk-api.azure-api.net/wealthdev/expense';

  Future<Map<String, dynamic>> fetchExpenses(String userId) async {
    try {
      debugPrint("Fetching expenses for userId: $userId");
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('Expenses')) {
          final List<dynamic> expensesList = jsonResponse['Expenses'];
          expenseList.value =
              expensesList.map((e) => ExpenseModel.fromJson(e)).toList();
          return {'success': true};
        } else {
          return {'success': false, 'message': 'No Expenses key in response'};
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
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
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
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

  Future<Map<String, dynamic>> deleteExpense(String expenseId) async {
    final url = Uri.parse('$baseUrl/$expenseId');

    try {
      debugPrint("🗑️ Deleting income with ID: $expenseId");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
      );

      if (response.statusCode == 200) {
        expenseList.removeWhere((expense) => expense.Id == expenseId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message':
              'Failed to delete expense (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> updateExpense(
    String userId,
    ExpenseModel expense,
  ) async {
    final expenseId = expense.Id;

    try {
      debugPrint("✏️ Updating expenses with ID: ${expense.Id}");
      debugPrint("➡️ Body: ${json.encode(expense.toJson())}");
      final response = await http.put(
        Uri.parse('$baseUrl/$expenseId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
        body: jsonEncode(expense.toJson()..addAll({'userId': userId})),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Expense updated successfully. Refreshing list...");

        final index = expenseList.indexWhere((e) => e.Id == expenseId);
        if (index != -1) {
          expenseList[index] = expense;
          expenseList.refresh();
        }

        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to update (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
}
