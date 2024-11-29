class UserStatistics {
  final int id;
  final int childId;
  final DateTime monthYear;
  final double totalTrainingHours;
  final double totalMatchHours;

  UserStatistics({
    required this.id,
    required this.childId,
    required this.monthYear,
    required this.totalTrainingHours,
    required this.totalMatchHours,
  });

  // Factory constructor to create a `UserStatistics` instance from JSON
  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      id: json['id'],
      childId: json['childId'],
      monthYear: DateTime.parse(json['monthYear']),
      totalTrainingHours: json['totalTrainingHours'].toDouble(),
      totalMatchHours: json['totalMatchHours'].toDouble(),
    );
  }

  // Method to convert a `UserStatistics` instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'monthYear': monthYear.toIso8601String(),
      'totalTrainingHours': totalTrainingHours,
      'totalMatchHours': totalMatchHours,
    };
  }
}
