class Statistics {
  final int childId;
  final String childName;
  final int trainingHours;
  final int matchHours;

  Statistics({
    required this.childId,
    required this.childName,
    required this.trainingHours,
    required this.matchHours,
  });

  /// Factory constructor to create a `Statistics` instance from a JSON object
  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      childId: json['ChildId'] ?? 0, // Default to 0 if `ChildId` is missing
      childName: json['ChildName'] ?? 'N/A', // Default to 'N/A' if missing
      trainingHours: json['TrainingHours']?.toInt() ?? 0, // Ensure it's an integer
      matchHours: json['MatchHours']?.toInt() ?? 0, // Ensure it's an integer
    );
  }

  /// Converts the `Statistics` object to JSON
  Map<String, dynamic> toJson() {
    return {
      'ChildId': childId,
      'ChildName': childName,
      'TrainingHours': trainingHours,
      'MatchHours': matchHours,
    };
  }
}
