class DoctorSlot {
  final String time;
  final bool available;

  DoctorSlot({
    required this.time,
    required this.available,
  });

  factory DoctorSlot.fromJson(Map<String, dynamic> json) {
    bool slotAvailability = false;

    if (json.containsKey('available')) {
      final raw = json['available'];

      if (raw is bool) {
        slotAvailability = raw;
      } else if (raw is int) {
        slotAvailability = raw == 1;
      } else if (raw is String) {
        slotAvailability = raw.toLowerCase() == 'true';
      }
    }

    return DoctorSlot(
      time: json['time'] ?? "",
      available: slotAvailability,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time,
      "available": available,
    };
  }
}