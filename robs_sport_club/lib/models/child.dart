class Child {
  final int id;
  final String childName;
  final int userId;
  final String teamNo;

  Child({
    required this.id,
    required this.childName,
    required this.userId,
    required this.teamNo,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      childName: json['childName'],
      userId: json['userId'],
      teamNo: json['teamNo'],
    );
  }
}
