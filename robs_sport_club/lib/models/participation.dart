class Participation {
  final String id;
  final String childName;
  final String participationType;
  final String teamNo;
  final String date;
  final String timeStart;
  final int duration; // Updated to int
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
      id: json['Id'] ?? '',
      childName: json['ChildName'] ?? '',
      participationType: json['ParticipationType'] ?? '',
      teamNo: json['TeamNo'] ?? '',
      date: json['Date'] ?? '',
      timeStart: json['TimeStart'] ?? '',
      duration: json['Duration'] != null ? int.tryParse(json['Duration'].toString()) ?? 0 : 0,
      location: json['Location'] ?? '',
      coach: json['Coach'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ChildName': childName,
      'ParticipationType': participationType,
      'TeamNo': teamNo,
      'Date': date,
      'TimeStart': timeStart,
      'Duration': duration,
      'Location': location,
      'Coach': coach,
    };
  }

  @override
  String toString() {
    return 'Participation(id: $id, childName: $childName, participationType: $participationType, teamNo: $teamNo, date: $date, timeStart: $timeStart, duration: $duration, location: $location, coach: $coach)';
  }
}
