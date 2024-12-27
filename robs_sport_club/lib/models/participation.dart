class Participation {
  final int id;
  final int childId;
  final String participationType;
  final String teamNo;
  final String date;
  final String location;
  final int duration;

  Participation({
    required this.id,
    required this.childId,
    required this.participationType,
    required this.teamNo,
    required this.date,
    required this.location,
    required this.duration,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'],
      childId: json['childId'],
      participationType: json['participationType'],
      teamNo: json['teamNo'],
      date: json['date'],
      location: json['location'],
      duration: json['duration'],
    );
  }
}
