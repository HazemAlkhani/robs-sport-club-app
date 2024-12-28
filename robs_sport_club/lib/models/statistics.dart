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

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      childId: json['ChildId'],
      childName: json['ChildName'] ?? 'N/A',
      trainingHours: json['TrainingHours'] ?? 0,
      matchHours: json['MatchHours'] ?? 0,
    );
  }
}
