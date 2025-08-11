import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _redirectUri = 'com.example.wealthapp://oauthredirect';
  static const List<String> _scopes = [
    'openid',
    'offline_access',
    'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/read',
    'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/write',
  ];
  static const String _discoveryUrl =
      'https://dynamicsmonkdev.b2clogin.com/tfp/dynamicsmonkdev.onmicrosoft.com/B2C_1_b2c_wealth_1/v2.0/.well-known/openid-configuration';

  // Decode JWT Payload
  Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT token');
    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final decodedBytes = base64Url.decode(normalized);
    final decodedPayload = utf8.decode(decodedBytes);
    return json.decode(decodedPayload);
  }

  // Print Token Data
  Future<void> printTokenData() async {
    try {
      final idToken = await getIdToken();
      if (idToken == null) {
        debugPrint("❌ No token found");
        return;
      }

      final payload = decodeJWT(idToken);
      debugPrint("🧾 Decoded JWT Payload:");
      payload.forEach((key, value) {
        debugPrint("🔑 $key: $value");
      });

      if (payload.containsKey('exp')) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(
          payload['exp'] * 1000,
        );
        debugPrint("⏰ Token expires at: $expiry");
      }
    } catch (e) {
      debugPrint("❌ Failed to decode JWT: $e");
    }
  }

  Future<void> login() async {
    if (isLoggingIn.value) {
      debugPrint("⚠️ Login already in progress.");
      return;
    }

    isLoggingIn.value = true;

    try {
      debugPrint("🌐 Performing interactive login...");
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          externalUserAgent:
              ExternalUserAgent.ephemeralAsWebAuthenticationSession,
          promptValues: ['login'],
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
        ),
      );

      if (result.idToken != null) {
        final payload = decodeJWT(result.idToken!);
        final name =
            (payload['name']?.toString().trim().isNotEmpty ?? false)
                ? payload['name']
                : '';
        final userEmail =
            payload['emails'] is List
                ? payload['emails'][0]
                : payload['email'] ?? '';
        final userIdValue = payload['sub'] ?? payload['oid'] ?? '';

        fullName.value = name;
        email.value = userEmail;
        userId.value = userIdValue;
        isLoggedIn.value = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result.accessToken ?? '');
        await prefs.setString('refreshToken', result.refreshToken ?? '');
        await prefs.setString('idToken', result.idToken!);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', name);
        await prefs.setString('userId', userIdValue);

        debugPrint("✅ login successful");
        debugPrint("👤 User ID: $userIdValue");
        debugPrint("👤 Email: $userEmail");
        debugPrint("🔐 JWT (idToken): ${result.idToken}");

        await sendUserDataToBackend(
          name: name,
          email: userEmail,
          userId: userIdValue,
          idToken: result.idToken ?? '',
        );

        await printTokenData();
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

  Future<void> sendUserDataToBackend({
    required String name,
    required String email,
    required String userId,
    required String idToken,
  }) async {
    final url = Uri.parse(
      'https://dynamicsmonk-api.azure-api.net/wealthdev/users',
    );

    final headers = {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $idToken',
      'Ocp-Apim-Subscription-Key': '507f2afb55654b58b949017a7d8c5f22',
    };

    final body = {
      'firstName': name,
      'lastname': "",
      'email': email,
      'phone': "",
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        final backendUserId = responseData['userId'];
        debugPrint("✅ User data sent to backend successfully: $backendUserId");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('DBid', backendUserId);

        Get.find<AuthController>().dbUserId.value = backendUserId;

        debugPrint(
          "📝 Saved DBid to SharedPreferences & AuthController: $backendUserId",
        );
      } else {
        debugPrint(
          "❌ Failed to send user data: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("❌ Error sending data to backend: $e");
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

      debugPrint("🟢 Found refreshToken. Forcing silent login...");
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final TokenResponse? result = await _appAuth.token(
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
        debugPrint("✅ Silent login success!");

        final storedEmail = prefs.getString('userEmail') ?? '';
        final storedName = prefs.getString('userName') ?? '';
        final storedUserId = prefs.getString('userId') ?? '';

        email.value = storedEmail;
        fullName.value = storedName;
        userId.value = storedUserId;

        await prefs.setString('accessToken', result.accessToken ?? '');
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          await prefs.setString('refreshToken', result.refreshToken!);
        }

        isLoggedIn.value = true;
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

    final idToken = await getIdToken();
    if (idToken == null) return;

    try {
      final url = Uri.parse('');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Name updated on backend");
      } else {
        debugPrint(
          "❌ Failed to update name on backend: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("❌ Error updating name on backend: $e");
    }
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken');
    final dbId = prefs.getString('DBid');

    if (idToken == null || dbId == null) return;

    final url = Uri.parse('http://192.168.1.24:7173/api/users/$dbId');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        debugPrint("👼 Fetch user success 👼");
        final data = jsonDecode(response.body);
        fullName.value = data['firstName'] ?? '';
        email.value = data['email'] ?? '';
        userId.value = data['userId'] ?? '';
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
        debugPrint("🪪 Stored DBid loaded: $storedDbId");

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
