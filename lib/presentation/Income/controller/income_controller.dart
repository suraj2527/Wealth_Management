import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/api/api_helper.dart';
import '../model/income_model.dart';

class IncomeController extends GetxController {
  var incomeList = <IncomeModel>[].obs;
  var totalIncome = 0.0.obs;

  Future<void> loadCachedIncomes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_incomes_$userId');

    if (cachedJson != null) {
      final List<dynamic> cachedList = json.decode(cachedJson);
      incomeList.value = cachedList.map((e) => IncomeModel.fromJson(e)).toList();

      totalIncome.value = incomeList.fold(0.0, (sum, item) => sum + item.amount);

      debugPrint("📦 Loaded ${incomeList.length} incomes from cache.");
    }
  }

  Future<void> saveIncomesToCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(incomeList.map((e) => e.toJson()).toList());
    await prefs.setString('cached_incomes_$userId', encoded);
    debugPrint("💾 Saved ${incomeList.length} incomes to cache.");
  }

  Future<Map<String, dynamic>> fetchIncomes(String userId, {bool useCacheFirst = true}) async {
    try {
      if (useCacheFirst) await loadCachedIncomes(userId);

      debugPrint("📥 Fetching incomes for userId: $userId");

      final response = await http.get(
        Uri.parse(ApiHelper.getIncomes(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      debugPrint("📡 GET incomes => Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        incomeList.value = jsonData.map((item) => IncomeModel.fromJson(item)).toList();

        totalIncome.value = incomeList.fold(0.0, (sum, item) => sum + item.amount);

        await saveIncomesToCache(userId);
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to fetch incomes (Status: ${response.statusCode})'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addIncome(IncomeModel income, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiHelper.addIncome()),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(income.toJson()..addAll({'userId': userId})),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        incomeList.insert(0, income);
        totalIncome.value += income.amount;

        await saveIncomesToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to add income (Status: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong while adding income.'};
    }
  }

  Future<Map<String, dynamic>> updateIncome(IncomeModel income, String userId) async {
    final incomeId = income.id;

    try {
      final response = await http.put(
        Uri.parse(ApiHelper.updateIncome(incomeId)),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(income.toJson()..addAll({'userId': userId})),
      );

      if (response.statusCode == 200) {
        final index = incomeList.indexWhere((i) => i.id == income.id);
        if (index != -1) incomeList[index] = income;

        totalIncome.value = incomeList.fold(0.0, (sum, item) => sum + item.amount);

        await saveIncomesToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to update income (Status: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong while updating income.'};
    }
  }

  Future<Map<String, dynamic>> deleteIncome(String incomeId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiHelper.deleteIncome(incomeId)),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        final removed = incomeList.firstWhereOrNull((i) => i.id == incomeId);
        if (removed != null) {
          incomeList.remove(removed);
          totalIncome.value -= removed.amount;
        }

        await saveIncomesToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to delete income (Status: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong while deleting income.'};
    }
  }

  void clearAllIncome(String userId) async {
    incomeList.clear();
    totalIncome.value = 0;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('cached_incomes_$userId');
  }
}
