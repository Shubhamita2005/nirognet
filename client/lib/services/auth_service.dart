import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000/api'; // ✅ FIXED
  final _storage = const FlutterSecureStorage();

  String _cleanToken(String token) {
    return token.trim().replaceAll('\n', '').replaceAll('\r', '');
  }

  // -----------------------
  // LOGIN
  // -----------------------
  Future<String> login(String email, String password) async {
    print('🔵 [AUTH_SERVICE] login() started');

    final response = await http.post(
      Uri.parse('$baseUrl/login'), // ✅ FIXED
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('📡 Status: ${response.statusCode}');
    print('📡 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = _cleanToken(data['access_token']);

      await _storage.write(key: 'access_token', value: token);

      print('✅ Token saved');
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // -----------------------
  // REGISTER
  // -----------------------
  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'), // ✅ FIXED
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Register failed: ${response.body}');
    }
  }

  // -----------------------
  // GET PROFILE
  // -----------------------
  Future<Map<String, dynamic>> getProfile(String token) async {
    token = _cleanToken(token);

    final response = await http.get(
      Uri.parse('$baseUrl/profile'), // ✅ FIXED
      headers: {
        'Authorization': 'Bearer $token', // ✅ IMPORTANT
        'Content-Type': 'application/json',
      },
    );

    print('📡 Profile Status: ${response.statusCode}');
    print('📡 Profile Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  // -----------------------
  // UPDATE PROFILE
  // -----------------------
  Future<void> updateProfile(
      String token, Map<String, dynamic> updatedData) async {
    token = _cleanToken(token);

    final response = await http.put(
      Uri.parse('$baseUrl/profile'), // ✅ FIXED
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed: ${response.body}');
    }

    print('✅ Profile updated');
  }

  // -----------------------
  // UPDATE HEALTH
  // -----------------------
  Future<void> updateHealthInfo(
      String token, Map<String, dynamic> healthData) async {
    token = _cleanToken(token);

    final response = await http.put(
      Uri.parse('$baseUrl/profile/health'), // ✅ FIXED
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(healthData),
    );

    if (response.statusCode != 200) {
      throw Exception('Health update failed: ${response.body}');
    }

    print('✅ Health updated');
  }

  // -----------------------
  // TOKEN HELPERS
  // -----------------------
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  // -----------------------
  // SIMPLIFIED METHODS
  // -----------------------
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }
    return await getProfile(token);
  }

  Future<void> updateCurrentUserProfile(
      Map<String, dynamic> updatedData) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }
    return await updateProfile(token, updatedData);
  }
}