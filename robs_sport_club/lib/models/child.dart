class Child {
  final int id;
  final String name;
  final String teamNo;
  final String sportType;

  Child({
    required this.id,
    required this.name,
    required this.teamNo,
    required this.sportType,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['Id'] ?? 0,
      name: json['ChildName'] ?? 'N/A',
      teamNo: json['TeamNo'] ?? 'N/A',
      sportType: json['SportType'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'ChildName': name,
      'TeamNo': teamNo,
      'SportType': sportType,
    };
  }
}
