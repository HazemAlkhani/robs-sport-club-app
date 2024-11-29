class Participation {
  final int id;
  final int childId;
  final String participationType;
  final String teamNo;
  final DateTime date;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String location;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Participation({
    required this.id,
    required this.childId,
    required this.participationType,
    required this.teamNo,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.location,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a `Participation` instance from JSON
  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      childId: json['childId'],
      participationType: json['participationType'],
      teamNo: json['teamNo'],
      date: DateTime.parse(json['date']),
      timeStart: DateTime.parse(json['timeStart']),
      timeEnd: DateTime.parse(json['timeEnd']),
      location: json['location'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a `Participation` instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'participationType': participationType,
      'teamNo': teamNo,
      'date': date.toIso8601String(),
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
