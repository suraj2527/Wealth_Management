import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/Helper/api_helper.dart';
import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  var expenseList = <ExpenseModel>[].obs;

  Future<void> _saveToCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cached_expenses_$userId',
      json.encode(expenseList.map((e) => e.toJson()).toList()),
    );
    debugPrint("💾 Saved ${expenseList.length} expenses to cache for userId: $userId");
  }

  Future<void> loadExpenseFromCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_expenses_$userId');
    if (cachedJson != null) {
      final List<dynamic> cachedList = json.decode(cachedJson);
      expenseList.value = cachedList.map((e) => ExpenseModel.fromJson(e)).toList();
      debugPrint("⚡ Loaded ${expenseList.length} expenses from cache for $userId");
    }
  }

  Future<Map<String, dynamic>> fetchExpenses(String userId, {bool useCacheFirst = true}) async {
    try {
      if (useCacheFirst) await loadExpenseFromCache(userId);

      final url = ApiHelper.getExpenses(userId);
      debugPrint("🌐 Fetching expenses for userId: $userId");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('Expenses')) {
          final List<dynamic> expensesList = jsonResponse['Expenses'];
          expenseList.value = expensesList.map((e) => ExpenseModel.fromJson(e)).toList();
          await _saveToCache(userId);
          return {'success': true};
        }
        return {'success': false, 'message': 'No Expenses key in response'};
      }

      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> submitExpenseAndRefresh(String userId, ExpenseModel expense) async {
    final fullExpenseJson = expense.toJson()..addAll({'userId': userId});

    try {
      final response = await http.post(
        Uri.parse(ApiHelper.addExpense()),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(fullExpenseJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchExpenses(userId, useCacheFirst: false);
        await _saveToCache(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to add expense (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> deleteExpense(String expenseId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiHelper.deleteExpense(expenseId)),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        expenseList.removeWhere((expense) => expense.Id == expenseId);
        await _saveToCache(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete expense (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> updateExpense(String userId, ExpenseModel expense) async {
    final expenseId = expense.Id;

    try {
      final response = await http.put(
        Uri.parse(ApiHelper.updateExpense(expenseId)),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(expense.toJson()..addAll({'userId': userId})),
      );

      if (response.statusCode == 200) {
        final index = expenseList.indexWhere((e) => e.Id == expenseId);
        if (index != -1) {
          expenseList[index] = expense;
          expenseList.refresh();
        }
        await fetchExpenses(userId, useCacheFirst: false);
        await _saveToCache(userId);
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

  void addExpense(ExpenseModel expense) => expenseList.add(expense);
  void removeExpense(int index) {
    if (index >= 0 && index < expenseList.length) expenseList.removeAt(index);
  }
  void clearExpenses() => expenseList.clear();
}
