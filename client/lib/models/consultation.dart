class Consultation {
  final int id;
  final int doctorId;
  final int userId;
  final int? appointmentTypeId;
  final String dateTime;
  final String status;

  Consultation({
    required this.id,
    required this.doctorId,
    required this.userId,
    this.appointmentTypeId,
    required this.dateTime,
    required this.status,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      appointmentTypeId: json['appointment_type_id'],
      dateTime: json['date_time'] ?? "",
      status: json['status'] ?? "pending",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "doctor_id": doctorId,
      "user_id": userId,
      "appointment_type_id": appointmentTypeId,
      "date_time": dateTime,
      "status": status,
    };
  }
}