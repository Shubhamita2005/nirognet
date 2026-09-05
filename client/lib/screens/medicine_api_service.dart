// lib/services/medicine_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'medicine_model.dart'; // Adjust path if needed

class MedicineApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator/Web
  // Assuming your Flask app runs on port 5000
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 

  // Matches: @medicine_bp.route('/medicines/category/<string:category>')
  static Future<List<Medicine>> getMedicinesByCategory(String category) async {
    try {
      // 1. Set up a variable for the URL
      String endpoint;

      // 2. Check if the category is "View All"
      if (category == "View All") {
        endpoint = '$baseUrl/medicines'; // Uses the "get all" route
      } else {
        endpoint = '$baseUrl/medicines/category/$category'; // Uses the specific category route
      }

      // 3. Make the request using the correct endpoint
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load medicines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  // Matches: @medicine_bp.route('/medicines/search')
  static Future<List<Medicine>> searchMedicines(String name) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/medicines/search?name=$name'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Medicine.fromJson(json)).toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}