// lib/services/symptom_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SymptomService {
  final _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'http://10.0.2.2:5000'; // ✅ CORRECT - Added :5000; // For Android Emulator

  Future<String> analyzeSymptom(String symptomText) async {
    // Get the authentication token from secure storage
    // String? token = await _storage.read(key: 'access_token');
    // if (token == null) {
    //   throw Exception('User is not logged in.');
    // }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/symptoms/analyze'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Send the token
        },
        body: jsonEncode({'symptoms': symptomText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply']; // Return the AI's text response
      } else {
        // Handle server errors (like 401 Unauthorized, 500 Internal Error)
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Symptom analysis failed: $e');
      throw Exception('Could not connect to the server. Please check your internet connection.');
    }
  }
}
