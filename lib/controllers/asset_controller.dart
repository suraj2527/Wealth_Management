import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/asset_model.dart';

class AssetController extends GetxController {
  final RxList<AssetModel> assetList = <AssetModel>[].obs;
  final String _apiUrl = 'http://localhost:7173/api/asset';

  Future<Map<String, dynamic>> submitAssetToServer(
    String userId,
    AssetModel asset,
  ) async {
    final fullAssetJson = asset.toJson()..addAll({'userId': userId});

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fullAssetJson),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchAssets(userId);
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to submit asset (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong while submitting asset.',
      };
    }
  }

  Future<Map<String, dynamic>> fetchAssets(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/user/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        assetList.assignAll(
          data.map((json) => AssetModel.fromJson(json)).toList(),
        );
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch assets (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong while fetching assets.',
      };
    }
  }

  void setAssets(List<AssetModel> assets) {
    assetList.assignAll(assets);
  }

  void clearAssets() {
    assetList.clear();
  }
}
