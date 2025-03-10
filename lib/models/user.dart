class User {
  final int id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}

class UserProfile {
  final int id;
  final String bio;
  final String avatarUrl;
  final int userId;

  UserProfile({
    required this.id,
    required this.bio,
    required this.avatarUrl,
    required this.userId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'userId': userId,
    };
  }
}
