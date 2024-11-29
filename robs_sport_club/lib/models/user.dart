class User {
  final int id;
  final String name;
  final String email;
  final String mobile;

  User({required this.id, required this.name, required this.email, required this.mobile});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'],
      name: json['Name'],
      email: json['Email'],
      mobile: json['Mobile'],
    );
  }
}
