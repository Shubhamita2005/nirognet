
class Medicine {
  final int id;
  final String name;
  final String category;
  final String description;
  final String? createdAt; 

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.createdAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
      description: json['description'] ?? 'No description available',
      createdAt: json['created_at'],
    );
  }
}