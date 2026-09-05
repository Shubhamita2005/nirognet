import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/specialty.dart';
import '../models/doctor.dart';
import '../utils/api_constants.dart';

class ConsultationService {
  // =========================
  // CLEAN TOKEN (SAFE VERSION)
  // =========================
  static String _cleanToken(String token) {
    if (token.isEmpty) return "";
    return token.replaceAll("Bearer ", "").trim();
  }

  // =========================
  // COMMON HEADERS BUILDER
  // =========================
  static Map<String, String> _headers(String token,
      {bool isJson = false}) {
    final clean = _cleanToken(token);

    return {
      "Authorization": "Bearer $clean",
      if (isJson) "Content-Type": "application/json",
    };
  }

  // =========================
  // GET ALL SPECIALTIES
  // =========================
  static Future<List<Specialty>> fetchSpecialties() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.specialties),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data =
            decoded is List ? decoded : decoded["specialties"] ?? [];

        return data.map((e) => Specialty.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load specialties");
      }
    } catch (e) {
      throw Exception("Specialty fetch error: $e");
    }
  }

  // =========================
  // GET DOCTORS BY SPECIALTY
  // =========================
  static Future<List<Doctor>> fetchDoctorsBySpecialty(
    int specialtyId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.doctorsBySpecialty(specialtyId)),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data =
            decoded is List ? decoded : decoded["doctors"] ?? [];

        return data.map((e) => Doctor.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load doctors");
      }
    } catch (e) {
      throw Exception("Doctor fetch error: $e");
    }
  }

  // =========================
  // FETCH DOCTOR SLOTS
  // =========================
  static Future<List<dynamic>> fetchDoctorSlots(
    int doctorId,
    String date,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.doctorSlots(doctorId, date)),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["slots"] ?? [];
      } else {
        throw Exception("Failed to load slots: ${response.body}");
      }
    } catch (e) {
      throw Exception("Slot fetch error: $e");
    }
  }

  // =========================
  // BOOK CONSULTATION
  // =========================
  static Future<int?> bookConsultation({
    required int doctorId,
    required String dateTime,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.consultations),
        headers: _headers(token, isJson: true),
        body: jsonEncode({
          "doctor_id": doctorId,
          "date_time": dateTime,
        }),
      );

      print("BOOK RESPONSE: ${response.statusCode}");
      print("BOOK BODY: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        // ✅ Handle nested response
        if (decoded["consultation"] != null &&
            decoded["consultation"]["id"] != null) {
          return decoded["consultation"]["id"];
        } else {
          throw Exception("No consultation ID returned");
        }
      } else {
        throw Exception("Booking failed: ${response.body}");
      }
    } catch (e) {
      print("BOOK ERROR: $e");
      return null;
    }
  }

  // =========================
  // GET USER CONSULTATIONS
  // =========================
  static Future<List<dynamic>> fetchMyConsultations(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.consultations),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) return decoded;

        return decoded["consultations"] ?? [];
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Consultation fetch error: $e");
    }
  }

  // =========================
  // UPDATE APPOINTMENT TYPE
  // =========================
  static Future<bool> updateConsultationType({
    required int consultationId,
    required int appointmentTypeId,
    required String token,
  }) async {
    try {
      final clean = _cleanToken(token);

      // 🔥 DEBUG (keep for now)
      print("TOKEN SENT: [$clean]");
      print("Consultation ID: $consultationId");
      print("Appointment Type: $appointmentTypeId");

      if (clean.isEmpty) {
        print("❌ ERROR: Token is empty!");
        return false;
      }

      final response = await http.put(
        Uri.parse(
          ApiConstants.consultationType(consultationId),
        ),
        headers: _headers(token, isJson: true),
        body: jsonEncode({
          "appointment_type_id": appointmentTypeId,
        }),
      );

      print("UPDATE TYPE RESPONSE: ${response.statusCode}");
      print("UPDATE TYPE BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE ERROR: $e");
      return false;
    }
  }
}