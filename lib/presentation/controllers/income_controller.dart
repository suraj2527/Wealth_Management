import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/income_model.dart';

class IncomeController extends GetxController {
  final String baseUrl = 'https://dynamicsmonk-api.azure-api.net/wealthdev';

  var incomeList = <IncomeModel>[].obs;
  var totalIncome = 0.0.obs;

  /// Load incomes from SharedPreferences
  Future<void> loadCachedIncomes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_incomes_$userId');

    if (cachedJson != null) {
      final List<dynamic> cachedList = json.decode(cachedJson);
      incomeList.value =
          cachedList.map((e) => IncomeModel.fromJson(e)).toList();

      totalIncome.value = incomeList.fold(
        0.0,
        (sum, item) => sum + item.amount,
      );

      debugPrint("📦 Loaded ${incomeList.length} incomes from cache.");
    }
  }

  /// Save incomes to SharedPreferences
  Future<void> saveIncomesToCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(incomeList.map((e) => e.toJson()).toList());
    await prefs.setString('cached_incomes_$userId', encoded);
    debugPrint("💾 Saved ${incomeList.length} incomes to cache.");
  }

  /// Fetch from API and update cache
Future<Map<String, dynamic>> fetchIncomes(String userId, {bool useCacheFirst = true}) async {
  try {
    if (useCacheFirst) {
      await loadCachedIncomes(userId); // Load cached data instantly
    }

    debugPrint("📥 Fetching incomes for userId: $userId");

    final response = await http.get(
      Uri.parse('$baseUrl/incomes/recent/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
      },
    );

    debugPrint("📡 GET /incomes/recent/$userId => Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      incomeList.value = jsonData.map((item) => IncomeModel.fromJson(item)).toList();

      totalIncome.value = incomeList.fold(0.0, (sum, item) => sum + item.amount);

      await saveIncomesToCache(userId);
      debugPrint("✅ Incomes fetched: ${incomeList.length} items");

      return {'success': true};
    }

    return {'success': false, 'message': '❌ Failed to fetch incomes (Status: ${response.statusCode})'};
  } catch (e) {
    debugPrint("❌ Error fetching incomes: $e");
    return {'success': false, 'message': e.toString()};
  }
}
  /// Add income & update cache
  Future<Map<String, dynamic>> addIncome(
      IncomeModel income, String userId) async {
    try {
      debugPrint("📤 Adding income for user: ${income.userId}");
      debugPrint("➡️ Body: ${json.encode(income.toJson())}");

      final response = await http.post(
        Uri.parse('$baseUrl/income'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key':
              '507f2afb55654b58b949017a7d8c5f22',
        },
        body: json.encode(income.toJson()),
      );

      debugPrint("📡 POST /income => Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        incomeList.insert(0, income);
        totalIncome.value += income.amount;

        await saveIncomesToCache(userId);

        debugPrint("✅ Income added successfully!");
        return {'success': true};
      } else {
        debugPrint("❌ Failed to add income: ${response.body}");
        return {
          'success': false,
          'message': 'Failed to add income (Status: ${response.statusCode})',
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message': 'Server is not running or not reachable.',
      };
    } catch (e) {
      debugPrint("❌ Error adding income: $e");
      return {
        'success': false,
        'message': 'Something went wrong while adding income.',
      };
    }
  }

  /// Update income & cache
  Future<Map<String, dynamic>> updateIncome(
      IncomeModel income, String userId) async {
    final incomeId = income.id;
    try {
      debugPrint("✏️ Updating income with ID: ${income.id}");
      debugPrint("➡️ Body: ${json.encode(income.toJson())}");

      final response = await http.put(
        Uri.parse('$baseUrl/income/$incomeId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key':
              '507f2afb55654b58b949017a7d8c5f22',
        },
        body: json.encode(income.toJson()),
      );

      debugPrint(
        "📡 PUT /income/${income.id} => Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final index = incomeList.indexWhere((i) => i.id == income.id);
        if (index != -1) {
          incomeList[index] = income;
        }

        totalIncome.value = incomeList.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );

        await saveIncomesToCache(userId);

        debugPrint("✅ Income updated successfully.");
        return {'success': true};
      } else {
        debugPrint("❌ Failed to update income: ${response.body}");
        return {
          'success': false,
          'message': 'Failed to update income (Status: ${response.statusCode})',
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message': 'Server is not running or not reachable.',
      };
    } catch (e) {
      debugPrint("❌ Error updating income: $e");
      return {
        'success': false,
        'message': 'Something went wrong while updating income.',
      };
    }
  }

  /// Delete income & update cache
  Future<Map<String, dynamic>> deleteIncome(
      String incomeId, String userId) async {
    try {
      debugPrint("🗑️ Deleting income with ID: $incomeId");

      final response = await http.delete(
        Uri.parse('$baseUrl/income/$incomeId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key':
              '507f2afb55654b58b949017a7d8c5f22',
        },
      );

      debugPrint(
        "📡 DELETE /income/$incomeId => Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final removed = incomeList.firstWhereOrNull((income) => income.id == incomeId);
        if (removed != null) {
          incomeList.remove(removed);
          totalIncome.value -= removed.amount;
        }

        await saveIncomesToCache(userId);

        debugPrint("✅ Income deleted successfully!");
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete income (Status: ${response.statusCode})',
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message': 'Server is not running or not reachable.',
      };
    } catch (e) {
      debugPrint("❌ Error deleting income: $e");
      return {
        'success': false,
        'message': 'Something went wrong while deleting income.',
      };
    }
  }

  void clearAllIncome(String userId) async {
    incomeList.clear();
    totalIncome.value = 0;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('cached_incomes_$userId');

    debugPrint("🧹 Cleared all income data & cache.");
  }
}
