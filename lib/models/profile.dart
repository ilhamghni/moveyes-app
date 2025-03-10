import 'package:moveyes_app/models/user.dart';

class Profile {
  final int id;
  final String bio;
  final String? avatarUrl;
  final String? nickname;
  final String? hobbies;
  final Map<String, dynamic>? socialMedia;
  final int userId;
  final User user;

  Profile({
    required this.id,
    required this.bio,
    this.avatarUrl,
    this.nickname,
    this.hobbies,
    this.socialMedia,
    required this.userId,
    required this.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'],
      nickname: json['nickname'],
      hobbies: json['hobbies'],
      socialMedia: json['socialMedia'],
      userId: json['userId'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'nickname': nickname,
      'hobbies': hobbies,
      'socialMedia': socialMedia,
      'userId': userId,
      'user': user.toJson(),
    };
  }

  // Create a copy of the profile with updated fields
  Profile copyWith({
    int? id,
    String? bio,
    String? avatarUrl,
    String? nickname,
    String? hobbies,
    Map<String, dynamic>? socialMedia,
    int? userId,
    User? user,
  }) {
    return Profile(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nickname: nickname ?? this.nickname,
      hobbies: hobbies ?? this.hobbies,
      socialMedia: socialMedia ?? this.socialMedia,
      userId: userId ?? this.userId,
      user: user ?? this.user,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
