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
      id: json['id'] ?? 0, // Default to 0 if id is null
      parentName: json['parentName'] ?? 'N/A', // Default to 'N/A' if parentName is null
      email: json['email'] ?? 'N/A', // Default to 'N/A' if email is null
      mobile: json['mobile'] ?? 'N/A', // Default to 'N/A' if mobile is null
      role: json['role'] ?? 'N/A', // Default to 'N/A' if role is null
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentName': parentName,
      'email': email,
      'mobile': mobile,
      'role': role,
    };
  }
}
