class User {
  final int id;
  final String parentName;
  final String email;
  final String mobile;
  final String role;

  User({
    required this.id,
    required this.parentName,
    required this.email,
    required this.mobile,
    required this.role,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      parentName: json['parentName'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
    );
  }
}
