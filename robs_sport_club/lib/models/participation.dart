class Participation {
  final String id;
  final String childName;
  final String participationType; // Should be "Training" or "Match"
  final String teamNo;
  final String date;
  final String timeStart;
  final int duration; // Duration in minutes
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
    final participationType = json['ParticipationType'] ?? '';
    if (participationType != 'Training' && participationType != 'Match') {
      throw FormatException(
          'Invalid participation type: $participationType. It must be "Training" or "Match".');
    }

    return Participation(
      id: json['Id']?.toString() ?? '', // Ensure id is always a string
      childName: json['ChildName'] ?? '',
      participationType: participationType,
      teamNo: json['TeamNo'] ?? '',
      date: json['Date'] ?? '',
      timeStart: json['TimeStart'] ?? '',
      duration: json['Duration'] != null
          ? int.tryParse(json['Duration'].toString()) ?? 0
          : 0,
      location: json['Location'] ?? '',
      coach: json['Coach'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    if (participationType != 'Training' && participationType != 'Match') {
      throw FormatException(
          'Invalid participation type: $participationType. It must be "Training" or "Match".');
    }

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
