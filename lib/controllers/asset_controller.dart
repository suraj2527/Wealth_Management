import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/asset_model.dart';

class AssetController extends GetxController {
  final RxList<AssetModel> assetList = <AssetModel>[].obs;
  final String baseUrl = 'http://192.168.1.24:7173/api/investments';

  Future<Map<String, dynamic>> submitAssetAndRefresh(
    String userId,
    AssetModel asset,
  ) async {
    final Map<String, dynamic> fullAssetJson =
        asset.toJson()..addAll({'userId': userId});

    debugPrint("🧾 Submitting Asset for userId: $userId");
    debugPrint("📦 Asset JSON: ${jsonEncode(fullAssetJson)}");

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fullAssetJson),
      );

      debugPrint("📬 Response Status: ${response.statusCode}");
      debugPrint("📩 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Asset added successfully. Refreshing list...");
        await fetchAssets(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to add asset (Status: ${response.statusCode})',
        };
      }
    } catch (e, stack) {
      debugPrint("❌ Exception while submitting asset: $e");
      debugPrint("🧠 StackTrace: $stack");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

  /// 📥 Fetch all assets for a user
  Future<Map<String, dynamic>> fetchAssets(String userId) async {
    final url = '$baseUrl/recent/$userId';

    debugPrint("🔍 Fetching assets for userId: $userId");
    debugPrint("🌐 GET: $url");

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint("📬 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        assetList.value = data.map((e) => AssetModel.fromJson(e)).toList();

        debugPrint("📊 Total Assets Fetched: ${assetList.length}");
        return {'success': true};
      } else {
        debugPrint("❌ Failed to fetch assets. Status: ${response.statusCode}");
        debugPrint("📩 Response Body: ${response.body}");
        return {
          'success': false,
          'message': 'Failed to fetch assets (Status: ${response.statusCode})',
        };
      }
    } catch (e, stack) {
      debugPrint("❌ Exception while fetching assets: $e");
      debugPrint("🧠 StackTrace: $stack");
      return {
        'success': false,
        'message': 'Something went wrong while fetching assets.',
      };
    }
  }

  void addAsset(AssetModel asset) {
    assetList.add(asset);
    debugPrint("🟢 Locally added asset to list. Total: ${assetList.length}");
  }

  void removeAsset(int index) {
    if (index >= 0 && index < assetList.length) {
      assetList.removeAt(index);
      debugPrint(
        "🔴 Removed asset at index $index. Total: ${assetList.length}",
      );
    }
  }

  void clearAssets() {
    assetList.clear();
    debugPrint("🧼 Cleared all assets.");
  }

  Future<Map<String, dynamic>> deleteAsset(String id, String userId) async {
    final url = '$baseUrl/$id';

    debugPrint("🗑️ Deleting asset with ID: $id");
    debugPrint("🌐 DELETE: $url");

    try {
      final response = await http.delete(Uri.parse(url));

      debugPrint("📬 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        await fetchAssets(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to delete asset (Status: ${response.statusCode})',
        };
      }
    } catch (e, stack) {
      debugPrint("❌ Exception while deleting asset: $e");
      debugPrint("🧠 StackTrace: $stack");
      return {
        'success': false,
        'message': 'Something went wrong. Could not delete asset.',
      };
    }
  }
}
