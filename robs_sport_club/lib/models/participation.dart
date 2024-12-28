class Participation {
  final String id;
  final String childName;
  final String participationType;
  final String teamNo;
  final String date;
  final String timeStart;
  final String duration;
  final String location;
  final String coach;

  Participation({
    required this.id,
    required this.childName,
    required this.participationType,
    required this.teamNo,
    required this.date,
    required this.timeStart,
    required this.duration,
    required this.location,
    required this.coach,
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['Id'] ?? 'N/A',
      childName: json['ChildName'] ?? 'N/A',
      participationType: json['ParticipationType'] ?? 'N/A',
      teamNo: json['TeamNo'] ?? 'N/A',
      date: json['Date'] ?? 'N/A',
      timeStart: json['TimeStart'] ?? 'N/A',
      duration: json['Duration']?.toString() ?? 'N/A',
      location: json['Location'] ?? 'N/A',
      coach: json['Coach'] ?? 'N/A',
    );
  }
}
