// import 'package:flutter/material.dart';
// import 'package:flutter_appauth/flutter_appauth.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:archive/archive.dart';

// class AuthController extends GetxController {
//   final FlutterAppAuth _appAuth = FlutterAppAuth();

//   var isLoggingIn = false.obs;
//   var fullName = ''.obs;
//   var email = ''.obs;
//   var mobile = ''.obs;
//   var userId = ''.obs;
//   var isLoggedIn = false.obs;

//   static const String _clientId = 'e4753ccc-04a3-429e-9a71-93526fd33922';
//   static const String _redirectUri = 'com.example.wealthapp://oauthredirect';
//   static const List<String> _scopes = [
//     'openid',
//     'offline_access',
//     'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/read',
//     'https://dynamicsmonkdev.onmicrosoft.com/oauth2/authresp/write',
//   ];
//   static const String _discoveryUrl =
//       'https://dynamicsmonkdev.b2clogin.com/tfp/dynamicsmonkdev.onmicrosoft.com/B2C_1_b2c_wealth_1/v2.0/.well-known/openid-configuration';

//   // 🔐 Compress JWT Token
//   String compressToken(String token) {
//     final stringBytes = utf8.encode(token);
//     final compressed = GZipEncoder().encode(stringBytes)!;
//     return base64Encode(compressed);
//   }

//   // 🔓 Decompress JWT Token
//   String decompressToken(String compressedToken) {
//     final compressed = base64Decode(compressedToken);
//     final decompressed = GZipDecoder().decodeBytes(compressed);
//     return utf8.decode(decompressed);
//   }

//   Future<void> login() async {
//     if (isLoggingIn.value) {
//       debugPrint("⚠️ Login already in progress.");
//       return;
//     }

//     isLoggingIn.value = true;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final storedRefreshToken = prefs.getString('refreshToken');
//       final storedEmail = prefs.getString('userEmail');
//       final storedName = prefs.getString('userName');
//       final storedUserId = prefs.getString('userId');

//       if (storedRefreshToken != null &&
//           storedEmail != null &&
//           storedName != null &&
//           storedUserId != null) {
//         debugPrint("🔄 Attempting silent login...");
//         await acquireTokenSilently();

//         email.value = storedEmail;
//         fullName.value = (storedName.trim().isNotEmpty) ? storedName : '';
//         userId.value = storedUserId;
//         isLoggedIn.value = true;

//         debugPrint("✅ Silent login successful");
//         return;
//       }

//       debugPrint("🌐 Performing interactive login...");
//       final result = await _appAuth.authorizeAndExchangeCode(
//         AuthorizationTokenRequest(
//           _clientId,
//           _redirectUri,
//           externalUserAgent:
//               ExternalUserAgent.ephemeralAsWebAuthenticationSession,
//           discoveryUrl: _discoveryUrl,
//           scopes: _scopes,
//         ),
//       );

//       if (result.idToken != null) {
//         final parts = result.idToken!.split('.');
//         final normalized = base64.normalize(parts[1]);
//         final payload = utf8.decode(base64Url.decode(normalized));
//         final Map<String, dynamic> userInfo = json.decode(payload);

//         final name = (userInfo['name']?.toString().trim().isNotEmpty ?? false)
//             ? userInfo['name']
//             : '';
//         final userEmail = userInfo['emails'] is List
//             ? userInfo['emails'][0]
//             : userInfo['email'] ?? '';
//         final userIdValue = userInfo['sub'] ?? userInfo['oid'] ?? '';

//         fullName.value = name;
//         email.value = userEmail;
//         userId.value = userIdValue;
//         isLoggedIn.value = true;

//         // 📝 Save compressed token
//         final compressedIdToken = compressToken(result.idToken!);

//         await prefs.setString('accessToken', result.accessToken ?? '');
//         await prefs.setString('refreshToken', result.refreshToken ?? '');
//         await prefs.setString('idToken', compressedIdToken);
//         await prefs.setString('userEmail', userEmail);
//         await prefs.setString('userName', name);
//         await prefs.setString('userId', userIdValue);

//         debugPrint("✅ login successful");
//         debugPrint("👤 User ID: $userIdValue");
//         debugPrint("👤 Email: $userEmail");
//         debugPrint("🔐 Compressed JWT (idToken): $compressedIdToken");
//       } else {
//         throw Exception("No id token received");
//       }
//     } catch (e) {
//       debugPrint("❌ Login failed: $e");
//       isLoggedIn.value = false;
//       rethrow;
//     } finally {
//       isLoggingIn.value = false;
//     }
//   }

//   Future<void> acquireTokenSilently() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString('refreshToken');
//       if (refreshToken == null) return;

//       final result = await _appAuth.token(
//         TokenRequest(
//           _clientId,
//           _redirectUri,
//           refreshToken: refreshToken,
//           scopes: _scopes,
//           discoveryUrl: _discoveryUrl,
//         ),
//       );

//       if (result.accessToken != null && result.idToken != null) {
//         final compressedIdToken = compressToken(result.idToken!);
//         await prefs.setString('accessToken', result.accessToken ?? '');
//         await prefs.setString('idToken', compressedIdToken);
//         debugPrint("✅ Silent token refreshed");
//         debugPrint("🔐 Compressed refreshed JWT (idToken): $compressedIdToken");
//       }
//     } catch (e) {
//       debugPrint("❌ Token refresh failed: $e");
//     }
//   }

//   Future<void> logout() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final path = prefs.getString('profileImagePath');
//       if (path != null) {
//         final file = File(path);
//         if (await file.exists()) await file.delete();
//         prefs.remove('profileImagePath');
//       }

//       await prefs.remove('accessToken');
//       await prefs.remove('refreshToken');
//       await prefs.remove('idToken');
//       await prefs.remove('userName');
//       await prefs.remove('userEmail');
//       await prefs.remove('userId');

//       fullName.value = '';
//       email.value = '';
//       mobile.value = '';
//       userId.value = '';
//       isLoggedIn.value = false;

//       debugPrint("✅ Logout complete, local state cleared");
//     } catch (e) {
//       debugPrint("❌ Logout failed: $e");
//       throw Exception("Logout error: $e");
//     }
//   }

//   void updateName(String newName) async {
//     fullName.value = newName;

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userName', newName);

//     debugPrint("📝 Name updated to: $newName");
//   }

//   Future<String?> getDecompressedIdToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final compressedIdToken = prefs.getString('idToken');
//     if (compressedIdToken == null) return null;

//     return decompressToken(compressedIdToken);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

class AuthController extends GetxController {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  var isLoggingIn = false.obs;
  var fullName = ''.obs;
  var email = ''.obs;
  var mobile = ''.obs;
  var userId = ''.obs;
  var isLoggedIn = false.obs;

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

  // 🔐 Compress JWT Token
  String compressToken(String token) {
    final stringBytes = utf8.encode(token);
    final compressed = GZipEncoder().encode(stringBytes)!;
    return base64Encode(compressed);
  }

  // 🔓 Decompress JWT Token
  String decompressToken(String compressedToken) {
    final compressed = base64Decode(compressedToken);
    final decompressed = GZipDecoder().decodeBytes(compressed);
    return utf8.decode(decompressed);
  }

  // 🔍 Decode JWT Payload
  Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT token');

    final payload = parts[1];
    final normalized = base64.normalize(payload);
    final decodedBytes = base64Url.decode(normalized);
    final decodedPayload = utf8.decode(decodedBytes);
    return json.decode(decodedPayload);
  }

  // 🧾 Debug Print Token Data
  Future<void> printTokenData() async {
    try {
      final idToken = await getDecompressedIdToken();
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

        final compressedIdToken = compressToken(result.idToken!);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('accessToken', result.accessToken ?? '');
        await prefs.setString('refreshToken', result.refreshToken ?? '');
        await prefs.setString('idToken', compressedIdToken);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', name);
        await prefs.setString('userId', userIdValue);

        debugPrint("✅ login successful");
        debugPrint("👤 User ID: $userIdValue");
        debugPrint("👤 Email: $userEmail");
        debugPrint("🔐 Compressed JWT (idToken): $compressedIdToken");

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

      final TokenRequest request = TokenRequest(
        _clientId,
        _redirectUri,
        refreshToken: storedRefreshToken,
        discoveryUrl: _discoveryUrl,
        scopes: _scopes,
        grantType: 'refresh_token', // ✅ Force refresh token grant
      );

      final TokenResponse? result = await _appAuth.token(request);

      if (result != null && result.accessToken != null) {
        debugPrint("✅ Silent login success!");

        // 🔄 Restore user info from prefs
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
        // debugPrint("❌ Silent login failed: null result or missing token");
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

  void updateName(String newName) async {
    fullName.value = newName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);

    debugPrint("📝 Name updated to: $newName");
  }

  Future<String?> getDecompressedIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    final compressedIdToken = prefs.getString('idToken');
    if (compressedIdToken == null) return null;

    return decompressToken(compressedIdToken);
  }
  Future<bool> trySilentLogin() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedRefreshToken = prefs.getString('refreshToken');
    final storedEmail = prefs.getString('userEmail');
    final storedName = prefs.getString('userName');
    final storedUserId = prefs.getString('userId');

    if (storedRefreshToken != null &&
        storedEmail != null &&
        storedName != null &&
        storedUserId != null) {
      debugPrint("🔄 Attempting silent login from SplashScreen...");
      await acquireTokenSilently(); 

      email.value = storedEmail;
      fullName.value = (storedName.trim().isNotEmpty) ? storedName : '';
      userId.value = storedUserId;
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



