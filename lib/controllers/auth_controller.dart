import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_app/Helper/api_helper.dart';
import 'dart:convert';
import 'dart:io';

class AuthController extends GetxController {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  var isLoggingIn = false.obs;
  var fullName = ''.obs;
  var email = ''.obs;
  var mobile = ''.obs;
  var userId = ''.obs;
  var isLoggedIn = false.obs;
  var dbUserId = ''.obs;

  static const String _clientId = 'e4753ccc-04a3-429e-9a71-93526fd33922';
  static const String _redirectUri = 'com.example.wealthapp://oauthredirect/';
  static const List<String> _scopes = [
    'openid',
    'offline_access',
    'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/read',
    'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/write',
  ];
  static const String _discoveryUrl =
      'https://dynamicsmonkdev.b2clogin.com/tfp/dynamicsmonkdev.onmicrosoft.com/B2C_1_b2c_wealth_1/v2.0/.well-known/openid-configuration';

  Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT token');
    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final decodedBytes = base64Url.decode(normalized);
    final decodedPayload = utf8.decode(decodedBytes);
    return json.decode(decodedPayload);
  }

  Future<void> login() async {
    if (isLoggingIn.value) return;
    isLoggingIn.value = true;

    try {
      debugPrint("🌐 Performing interactive login...");
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          externalUserAgent: ExternalUserAgent.ephemeralAsWebAuthenticationSession,
          promptValues: ['login'],
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
        ),
      );

      if (result.idToken != null) {
        final payload = decodeJWT(result.idToken!);
        final name = payload['name'] ?? '';
        final userEmail = payload['emails'] is List
            ? payload['emails'][0]
            : payload['email'] ?? '';
        final userIdValue = payload['sub'] ?? payload['oid'] ?? '';

        fullName.value = name;
        email.value = userEmail;
        userId.value = userIdValue;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result.accessToken ?? '');
        await prefs.setString('refreshToken', result.refreshToken ?? '');
        await prefs.setString('idToken', result.idToken!);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', name);
        await prefs.setString('userId', userIdValue);

        debugPrint("✅ Azure login successful");
        isLoggedIn.value = true;
        // final backendSuccess = await sendUserDataToBackend(
        //   name: name,
        //   email: userEmail,
        //   userId: userIdValue,
        //   idToken: result.idToken!,
        // );

        // if (backendSuccess) {
        //   isLoggedIn.value = true;
        // } else {
        //   isLoggedIn.value = false;
        //   throw Exception("Backend registration failed");
        // }
      } else {
        throw Exception("No id token received");
      }
    } catch (e) {
      debugPrint("❌ Login failed: $e");
      isLoggedIn.value = false;
      rethrow;
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<bool> sendUserDataToBackend({
    required String name,
    required String email,
    required String userId,
    required String idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiHelper.addUser()), 
        headers: {
          'Content-Type': 'application/json',
          'Ocp-Apim-Subscription-Key': ApiHelper.subscriptionKey,
        },
        body: jsonEncode({
          'firstName': name,
          'lastname': '',
          'email': email,
          'phone': '',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final backendUserId = responseData['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('DBid', backendUserId);
        dbUserId.value = backendUserId;

        debugPrint("✅ User registered in backend: $backendUserId");
        return true;
      } else {
        debugPrint("❌ Backend failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error sending data to backend: $e");
      return false;
    }
  }

  Future<void> acquireTokenSilently() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString('refreshToken');

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        debugPrint("⚠️ No stored refresh token found.");
        isLoggedIn.value = false;
        return;
      }

      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          refreshToken: storedRefreshToken,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
          grantType: 'refresh_token',
        ),
      );

      if (result != null && result.accessToken != null) {
        await prefs.setString('accessToken', result.accessToken ?? '');
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          await prefs.setString('refreshToken', result.refreshToken!);
        }

        isLoggedIn.value = true;
        debugPrint("✅ Silent login success!");
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint("❌ Silent login exception: $e");
      isLoggedIn.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final path = prefs.getString('profileImagePath');
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
        prefs.remove('profileImagePath');
      }

      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('idToken');
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      await prefs.remove('userId');
      await prefs.remove('DBid');

      dbUserId.value = '';
      fullName.value = '';
      email.value = '';
      mobile.value = '';
      userId.value = '';
      isLoggedIn.value = false;

      debugPrint("✅ Logout complete, local state cleared");
    } catch (e) {
      debugPrint("❌ Logout failed: $e");
      throw Exception("Logout error: $e");
    }
  }

  Future<void> updateName(String newName) async {
    fullName.value = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    debugPrint("📝 Name updated locally to: $newName");
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken');
    final dbId = prefs.getString('DBid');
    if (idToken == null || dbId == null) return;

    try {
      final response = await http.get(
        Uri.parse('ApiHelper.getUserProfile(dbId)'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        fullName.value = data['firstName'] ?? '';
        email.value = data['email'] ?? '';
        userId.value = data['userId'] ?? '';
        debugPrint("👼 User profile fetched successfully");
      } else {
        debugPrint("❌ Fetch failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Fetch error: $e");
    }
  }

  Future<String?> getIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idToken');
  }

  Future<bool> trySilentLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRefreshToken = prefs.getString('refreshToken');
      final storedEmail = prefs.getString('userEmail');
      final storedName = prefs.getString('userName');
      final storedUserId = prefs.getString('userId');
      final storedDbId = prefs.getString('DBid');

      if (storedRefreshToken != null &&
          storedEmail != null &&
          storedName != null &&
          storedUserId != null &&
          storedDbId != null) {
        debugPrint("🔄 Attempting silent login from SplashScreen...");
        await acquireTokenSilently();

        email.value = storedEmail;
        fullName.value = storedName.trim().isNotEmpty ? storedName : '';
        userId.value = storedUserId;
        dbUserId.value = storedDbId;
        isLoggedIn.value = true;

        debugPrint("✅ Silent login successful from Splash");
        return true;
      } else {
        debugPrint("⚠️ No stored credentials found");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Silent login failed: $e");
      return false;
    }
  }
}
