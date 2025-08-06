import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/income_model.dart';
import 'package:flutter/foundation.dart';

class IncomeController extends GetxController {
  final String baseUrl = 'https://dynamicsmonk-api.azure-api.net/wealthdev';

  var incomeList = <IncomeModel>[].obs;
  var totalIncome = 0.0.obs;

  Future<Map<String, dynamic>> fetchIncomes(String userId) async {
    try {
      debugPrint("📥 Fetching incomes for userId: $userId");

      final response = await http.get(
        Uri.parse('$baseUrl/incomes/recent/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
      );

      debugPrint(
        "📡 GET /incomes/recent/$userId => Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        incomeList.value =
            jsonData.map((item) => IncomeModel.fromJson(item)).toList();
        totalIncome.value = incomeList.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        debugPrint("✅ Incomes fetched: ${incomeList.length} items");

        return {'success': true};
      } else {
        return {
          'success': false,
          'message':
              '❌ Failed to fetch incomes (Status: ${response.statusCode})',
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message': 'Server is not running or not reachable.',
      };
    } catch (e) {
      debugPrint("❌ Error fetching incomes: $e");
      return {
        'success': false,
        'message': 'Something went wrong while fetching incomes.',
      };
    }
  }

  Future<Map<String, dynamic>> addIncome(IncomeModel income) async {
    try {
      debugPrint("📤 Adding income for user: ${income.userId}");
      debugPrint("➡️ Body: ${json.encode(income.toJson())}");

      final response = await http.post(
        Uri.parse('$baseUrl/income'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
        body: json.encode(income.toJson()),
      );

      debugPrint("📡 POST /income => Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        incomeList.insert(0, income);
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

  Future<Map<String, dynamic>> deleteIncome(String incomeId) async {
    try {
      debugPrint("🗑️ Deleting income with ID: $incomeId");

      final response = await http.delete(
        Uri.parse('$baseUrl/income/$incomeId'),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
        },
      );

      debugPrint(
        "📡 DELETE /income/$incomeId => Status: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        incomeList.removeWhere((income) => income.id == incomeId);
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

  void clearAllIncome() {
    incomeList.clear();
    totalIncome.value = 0;
    debugPrint("🧹 Cleared all income data.");
  }
}
