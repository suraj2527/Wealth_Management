import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/api/api_helper.dart';
import '../model/asset_model.dart';

class AssetController extends GetxController {
  final RxList<AssetModel> assetList = <AssetModel>[].obs;

  Future<void> _saveToCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cached_assets_$userId',
      json.encode(assetList.map((e) => e.toJson()).toList()),
    );
    debugPrint("💾 Saved ${assetList.length} assets to cache for userId: $userId");
  }

  Future<void> loadAssetsFromCache(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('cached_assets_$userId');
    if (cachedJson != null) {
      final List<dynamic> cachedList = json.decode(cachedJson);
      assetList.value = cachedList.map((e) => AssetModel.fromJson(e)).toList();
      debugPrint("⚡ Loaded ${assetList.length} assets from cache for $userId");
    }
  }

  Future<Map<String, dynamic>> submitAssetAndRefresh(
    String userId,
    AssetModel asset,
  ) async {
    final Map<String, dynamic> fullAssetJson =
        asset.toJson()..addAll({'userId': userId});

    try {
      final response = await http.post(
        Uri.parse(ApiHelper.addAsset()),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(fullAssetJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAssets(userId, useCacheFirst: false);
        await _saveToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to add asset'};
      }
    } catch (_) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> fetchAssets(
    String userId, {
    bool useCacheFirst = true,
  }) async {
    try {
      if (useCacheFirst) {
        await loadAssetsFromCache(userId);
      }

      final url = ApiHelper.getAssets(userId);
      debugPrint("💰 Fetching assets for userId: $userId");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        assetList.value = data.map((e) => AssetModel.fromJson(e)).toList();
        await _saveToCache(userId);
        return {'success': true};
      }

      return {'success': false, 'message': 'Failed to fetch assets'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateAsset(
    String userId,
    AssetModel asset,
  ) async {
    final url = ApiHelper.deleteAsset(asset.id); 
    final Map<String, dynamic> updatedAssetJson =
        asset.toJson()..addAll({'userId': userId});

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode(updatedAssetJson),
      );

      if (response.statusCode == 200) {
        final index = assetList.indexWhere((e) => e.id == asset.id);
        if (index != -1) {
          assetList[index] = asset;
          assetList.refresh();
        }
        await fetchAssets(userId, useCacheFirst: false);
        await _saveToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to update asset'};
      }
    } catch (_) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  Future<Map<String, dynamic>> deleteAsset(String id, String userId) async {
    final url = ApiHelper.deleteAsset(id);
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
      );

      if (response.statusCode == 200) {
        await fetchAssets(userId, useCacheFirst: false);
        await _saveToCache(userId);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Failed to delete asset'};
      }
    } catch (_) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }
}
