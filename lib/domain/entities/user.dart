class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final String? role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.role,
    required this.createdAt,
  });

  String get name => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  @override // Menambahkan anotasi @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}