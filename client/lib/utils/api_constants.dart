class ApiConstants {
  // =========================
  // BASE URL
  // =========================
  // Android Emulator
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // If using physical device, replace with:
  // static const String baseUrl = "http://YOUR_LOCAL_IP:5000/api";

  // =========================
  // AUTH
  // =========================
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String profile = "$baseUrl/profile";

  // =========================
  // SPECIALTIES
  // =========================
  static const String specialties = "$baseUrl/specialties";

  static String doctorsBySpecialty(int specialtyId) =>
      "$baseUrl/specialties/$specialtyId/doctors";

  // =========================
  // DOCTOR SLOTS
  // =========================
  static String doctorSlots(int doctorId, String date) =>
      "$baseUrl/doctors/$doctorId/slots?date=$date";

  // =========================
  // CONSULTATIONS
  // =========================
  static const String consultations = "$baseUrl/consultations";

  static String consultationType(int consultationId) =>
      "$baseUrl/consultations/$consultationId/type";

  // =========================
  // HOSPITALS
  // =========================
  static const String hospitals = "$baseUrl/hospitals";

  // =========================
  // MEDICINES
  // =========================
  static const String medicines = "$baseUrl/medicines";

  // =========================
  // EMERGENCY
  // =========================
  static const String emergency = "$baseUrl/emergency";
}