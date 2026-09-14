import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'device_service.dart';

class AuthService {
  static const String _baseUrl =
      'https://evrak-backend-production.up.railway.app/api/users';

  // Hassas olan JWT token burada tutulacak.
  static const String _tokenKey = 'notla_auth_token';

  // Hassas olmayan kullanıcı bilgileri SharedPreferences'ta kalabilir.
  static const String _userIdKey = 'notla_user_id';
  static const String _nameKey = 'notla_user_name';
  static const String _emailKey = 'notla_user_email';
  static const String _phoneKey = 'notla_user_phone';
  static const String _addressKey = 'notla_user_address';

  static const FlutterSecureStorage _secureStorage =
  FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // =========================================================
  // OTURUM KONTROLÜ
  // =========================================================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  // =========================================================
  // TOKEN
  // =========================================================

  static Future<String?> getToken() async {
    return await _secureStorage.read(
      key: _tokenKey,
    );
  }

  // =========================================================
  // KULLANICI ID
  // =========================================================

  static Future<int?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_userIdKey);
  }

  // =========================================================
  // KAYIT
  // =========================================================

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    final deviceId = await DeviceService.getDeviceId();

    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'address': address.trim(),
        'password': password,
        'device_id': deviceId,
      }),
    );

    return _handleAuthResponse(response);
  }

  // =========================================================
  // GİRİŞ
  // =========================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final deviceId = await DeviceService.getDeviceId();

    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
        'device_id': deviceId,
      }),
    );

    return _handleAuthResponse(response);
  }

  // =========================================================
  // SUNUCU CEVABI
  // =========================================================

  static Future<Map<String, dynamic>> _handleAuthResponse(
      http.Response response,
      ) async {
    Map<String, dynamic> data;

    try {
      data = Map<String, dynamic>.from(
        jsonDecode(
          utf8.decode(response.bodyBytes),
        ),
      );
    } catch (_) {
      throw Exception(
        'Sunucudan geçersiz bir cevap alındı.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw Exception(
        data['error'] ??
            data['message'] ??
            'Giriş işlemi gerçekleştirilemedi.',
      );
    }

    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'])
        : <String, dynamic>{};

    final token = data['token']?.toString() ?? '';

    final userId = int.tryParse(
      (user['id'] ?? data['user_id'] ?? '').toString(),
    );

    if (token.trim().isEmpty || userId == null) {
      throw Exception(
        'Sunucudan kullanıcı oturumu alınamadı.',
      );
    }

    // JWT TOKEN GÜVENLİ ALANA YAZILIYOR
    await _secureStorage.write(
      key: _tokenKey,
      value: token,
    );

    // Hassas olmayan kullanıcı bilgileri
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(
      _userIdKey,
      userId,
    );

    await preferences.setString(
      _nameKey,
      (user['name'] ?? data['name'] ?? '').toString(),
    );

    await preferences.setString(
      _emailKey,
      (user['email'] ?? data['email'] ?? '').toString(),
    );
    await preferences.setString(
      _phoneKey,
      (user['phone'] ?? data['phone'] ?? '').toString(),
    );

    await preferences.setString(
      _addressKey,
      (user['address'] ?? data['address'] ?? '').toString(),
    );
    return data;
  }

  // =========================================================
  // ÇIKIŞ
  // =========================================================

  static Future<void> logout() async {
    // Güvenli alandaki JWT silinir.
    await _secureStorage.delete(
      key: _tokenKey,
    );

    // Kullanıcı bilgileri temizlenir.
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_userIdKey);
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_phoneKey);
    await preferences.remove(_addressKey);

    // Eski sürümden kalmış olabilecek token varsa onu da temizle.
    await preferences.remove(_tokenKey);
  }
  static Future<String> getPhone() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_phoneKey) ?? '';
  }

  static Future<String> getAddress() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_addressKey) ?? '';
  }
}