import 'dart:core';

class User {
  final String username;
  final String token;
  final String email;
  final List<dynamic> flowers;

  User({
    required this.username,
    required this.token,
    required this.email,
    required this.flowers
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'token': token,
    'email': email,
    'flowers': flowers,
  };

  static User fromJson(Map<String, dynamic> json) => User(
    username: json['username'] ?? json['login'], // login с бэка
    token: json['token'],
    email: json['email'],
    flowers: json['flowers'],
  );
}
