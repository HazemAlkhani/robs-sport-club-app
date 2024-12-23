class User {
  final int id;
  final String name;
  final String email;
  final String mobile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
  });

  // Factory constructor to create a `User` instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Updated key to match standard JSON naming
      name: json['name'], // Updated key to match standard JSON naming
      email: json['email'], // Updated key to match standard JSON naming
      mobile: json['mobile'], // Updated key to match standard JSON naming
    );
  }

  // Method to convert a `User` instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
    };
  }
}
