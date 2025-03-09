class Profile {
  final int id;
  final String bio;
  final String avatarUrl;
  final int userId;
  final User user;

  Profile({
    required this.id,
    required this.bio,
    required this.avatarUrl,
    required this.userId,
    required this.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      userId: json['userId'],
      user: User.fromJson(json['user']),
    );
  }
}

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
}
