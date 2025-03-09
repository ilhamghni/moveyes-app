class User {
  final int id;
  final String email;
  final String name;
  final String createdAt;
  final String updatedAt;
  final UserProfile profile;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      profile: UserProfile.fromJson(json['profile']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profile': profile.toJson(),
    };
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
