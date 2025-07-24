import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/income_model.dart';

class IncomeController extends GetxController {
  final String baseUrl = 'http://localhost:7173/api';

  var incomeList = <IncomeModel>[].obs;
  var totalIncome = 0.0.obs;

  Future<Map<String, dynamic>> fetchIncomes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/income/user/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        incomeList.value =
            jsonData.map((item) => IncomeModel.fromJson(item)).toList();
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch incomes (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong while fetching incomes.'
      };
    }
  }

  Future<Map<String, dynamic>> fetchTotalIncome(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/income/summary/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        totalIncome.value = (data['totalIncome'] ?? 0).toDouble();
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch total income (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong while fetching total income.'
      };
    }
  }

  Future<Map<String, dynamic>> addIncome(IncomeModel income) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/income'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(income.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        incomeList.insert(0, income);
        await fetchTotalIncome(income.userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to add income (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong while adding income.'
      };
    }
  }

  void clearAllIncome() {
    incomeList.clear();
    totalIncome.value = 0;
  }
}
