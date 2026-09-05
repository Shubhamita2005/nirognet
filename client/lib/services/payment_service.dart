import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {

  static const String baseUrl = "http://10.0.2.2:5000";
  static Map<String, String> _authHeaders(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
  // =========================
  // CREATE ONLINE PAYMENT
  // =========================
  static Future<Map<String, dynamic>?> createPayment({
    required int consultationId,
    required int appointmentTypeId,
    required String token,
  }) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/api/payments/create"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode({
          "consultation_id": consultationId,
          "appointment_type_id": appointmentTypeId,
        }),
      );

      print("PAYMENT STATUS: ${response.statusCode}");
      print("PAYMENT BODY: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        return jsonDecode(response.body);
      }

      return null;

    } catch (e) {

      print("PAYMENT ERROR: $e");
      return null;
    }
  }

  // =========================
  // VERIFY ONLINE PAYMENT
  // =========================
  static Future<bool> verifyPayment({
    required int consultationId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String token,
  }) async {

    try {

      final response = await http.post(
        Uri.parse("$baseUrl/api/payments/verify"),

        headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer $token",
},

        body: jsonEncode({
          "consultation_id": consultationId,
          "razorpay_order_id": razorpayOrderId,
          "razorpay_payment_id": razorpayPaymentId,
          "razorpay_signature": razorpaySignature,
        }),
      );

      print("VERIFY STATUS: ${response.statusCode}");
      print("VERIFY BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {

      print("VERIFY ERROR: $e");
      return false;
    }
  }

  // =========================
  // CREATE OFFLINE PAYMENT
  // =========================
  static Future<bool> createOfflinePayment({
    required int consultationId,
    required String token,
  }) async {

    try {

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/payments/offline",
        ),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode({
          "consultation_id": consultationId,
        }),
      );

      print(
        "OFFLINE PAYMENT STATUS: ${response.statusCode}",
      );

      print(
        "OFFLINE PAYMENT BODY: ${response.body}",
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;

    } catch (e) {

      print("OFFLINE PAYMENT ERROR: $e");

      return false;
    }
  }
}