class Doctor {
  final int id;
  final String name;
  final String hospital;
  final bool isAvailable;

  // Multiple schedules/slots
  final List<Map<String, String>> slots;

  final int fee;

  // Primary display fields
  final String date;
  final String time;

  Doctor({
    required this.id,
    required this.name,
    required this.hospital,
    required this.isAvailable,
    required this.slots,
    required this.date,
    required this.time,
    required this.fee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {

    //////////////////////////////////////////////////////
    // AVAILABILITY PARSER
    //////////////////////////////////////////////////////

    bool availability = true;

    final rawAvailability =
        json['available'] ??
        json['is_available'] ??
        true;

    if (rawAvailability is bool) {
      availability = rawAvailability;
    } else if (rawAvailability is int) {
      availability = rawAvailability == 1;
    } else if (rawAvailability is String) {
      availability =
          rawAvailability.toLowerCase() == 'true';
    }

    //////////////////////////////////////////////////////
    // DAY FIELD
    //////////////////////////////////////////////////////

    String day =
        json['day_of_week'] ??
        json['day'] ??
        json['date'] ??
        "No Day";

    //////////////////////////////////////////////////////
    // TIME RANGE
    //////////////////////////////////////////////////////

    String startTime = json['start_time'] ?? "";
    String endTime = json['end_time'] ?? "";

    String formattedTime =
        startTime.isNotEmpty && endTime.isNotEmpty
            ? "$startTime - $endTime"
            : "No Time";

    //////////////////////////////////////////////////////
    // SLOT OBJECT
    //////////////////////////////////////////////////////

    final slot = {
      "day": day,
      "time": formattedTime,
    };

    return Doctor(
      id: json['doctor_id'] ?? json['id'] ?? 0,

      name:
          json['doctor_name'] ??
          json['name'] ??
          "No Name",

      hospital:
          json['hospital'] ??
          "Unknown Hospital",

      isAvailable: availability,

      fee: json['fee'] ?? 0,

      slots: [slot],

      // Primary fields
      date: day,
      time: formattedTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "doctor_id": id,
      "doctor_name": name,
      "hospital": hospital,
      "available": isAvailable,
      "slots": slots,
      "date": date,
      "time": time,
      "fee": fee,
    };
  }

  //////////////////////////////////////////////////////
  // COPY WITH
  //////////////////////////////////////////////////////

  Doctor copyWith({
    int? id,
    String? name,
    String? hospital,
    bool? isAvailable,
    List<Map<String, String>>? slots,
    String? date,
    String? time,
    int? fee,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      hospital: hospital ?? this.hospital,
      isAvailable: isAvailable ?? this.isAvailable,
      slots: slots ?? this.slots,
      date: date ?? this.date,
      time: time ?? this.time,
      fee: fee ?? this.fee,
    );
  }
}