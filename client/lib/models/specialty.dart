class Specialty {
  final int id;
  final String name;

  Specialty({
    required this.id,
    required this.name,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown Specialty",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  Specialty copyWith({
    int? id,
    String? name,
  }) {
    return Specialty(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}