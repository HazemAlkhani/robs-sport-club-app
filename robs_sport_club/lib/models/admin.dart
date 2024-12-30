class Admin {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String role;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
  });

  // Convert JSON to Admin object
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? 0, // Default to 0 if id is null
      name: json['name'] ?? 'N/A', // Default to 'N/A' if name is null
      email: json['email'] ?? 'N/A', // Default to 'N/A' if email is null
      mobile: json['mobile'] ?? 'N/A', // Default to 'N/A' if mobile is null
      role: json['role'] ?? 'N/A', // Default to 'N/A' if role is null
    );
  }

  // Convert Admin object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
    };
  }
}
