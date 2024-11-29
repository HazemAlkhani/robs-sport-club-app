
class Child {
  final int id;
  final String childName;
  final int userId; // Corresponds to the parent user
  final String teamNo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.childName,
    required this.userId,
    required this.teamNo,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a `Child` instance from JSON
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      childName: json['childName'],
      userId: json['userId'],
      teamNo: json['teamNo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a `Child` instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childName': childName,
      'userId': userId,
      'teamNo': teamNo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
