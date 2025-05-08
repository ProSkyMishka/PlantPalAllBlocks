// lib/shared/services/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'local_storage.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  final _storage = LocalStorage();
  final _baseUrl = 'http://localhost:8080/auth'; // замени на свой

  bool _isValidUsername(String u) => RegExp(r'^[A-Za-z0-9]+$').hasMatch(u);
  bool _isValidPassword(String p) => RegExp(r'^(?=.*\d)[A-Za-z0-9]{8,}$').hasMatch(p);
  bool _isValidEmail(String m) => RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(m);

  Future<User?> login(String u, String p) async {
    if (!_isValidUsername(u) || !_isValidPassword(p)) {
      throw AuthException('Неверные имя или пароль');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': u, 'password': p}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      User? user = User(username: u, token: token, email: "", flowers: []);
      await _storage.saveUser(user);
      user = await getCurrent();
      return user;
    } else {
      throw AuthException(jsonDecode(response.body)['reason'] ?? 'Ошибка входа');
    }
  }

  Future<User?> register(String u, String p, String m) async {
    if (!_isValidUsername(u)) {
      throw AuthException('Некорректный логин');
    }
    if (!_isValidPassword(p)) {
      throw AuthException('Некорректный пароль');
    }
    if (!_isValidEmail(m)) {
      throw AuthException('Некорректный email');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login': u, 'password': p, 'email': m}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      User? user = User(username: u, token: token, email: m, flowers: []);
      await _storage.saveUser(user);
      user = await getCurrent();
      return user;
    } else {
      throw AuthException(jsonDecode(response.body)['reason'] ?? 'Ошибка регистрации');
    }
  }

  Future<bool> check(String u, String p, String m) async {
    if (!_isValidUsername(u)) {
      throw AuthException('Некорректный логин');
    }
    if (!_isValidPassword(p)) {
      throw AuthException('Некорректный пароль');
    }
    if (!_isValidEmail(m)) {
      throw AuthException('Некорректный email');
    }
    return true;
  }

  Future<void> logout() => _storage.clear();

  Future<User?> getCurrent() async {
    final user = await _storage.getUser();
    if (user == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {'Authorization': 'Bearer ${user.token}'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User(username: json['login'], token: user.token, email: json['email'], flowers: json['flowers']);
    } else {
      await _storage.clear();
      return null;
    }
  }

  Future<User> changeUsername(String newUsername) async {
    final curr = await getCurrent();
    if (curr == null) throw AuthException('Нет авторизации');

    if (!_isValidUsername(newUsername)) {
      throw AuthException('Имя должно содержать только латинские буквы и цифры');
    }

    return _updateUser(newUsername, curr.email ?? '', curr.token, curr.flowers);
  }

  Future<User> changeEmail(String newEmail) async {
    final curr = await getCurrent();
    if (curr == null) throw AuthException('Нет авторизации');

    if (!_isValidEmail(newEmail)) {
      throw AuthException('Некорректный email');
    }

    return _updateUser(curr.username, newEmail, curr.token, curr.flowers);
  }

  Future<User> changePassword(String oldPass, String newPass) async {
    final curr = await getCurrent();
    if (curr == null) throw AuthException('Нет авторизации');

    if (!_isValidPassword(newPass)) {
      throw AuthException('Новый пароль должен быть минимум 8 символов и содержать цифру');
    }

    return User(username: curr.username, token: curr.token, email: curr.email, flowers: curr.flowers);
  }

  Future<User> addFlowerToUser(String newFlower) async {
    final curr = await getCurrent();
    if (curr == null) throw AuthException('Нет авторизации');

    final flowers = curr.flowers;
    flowers.add(newFlower);

    return _updateUser(curr.username, curr.email, curr.token, flowers);
  }

  Future<User> _updateUser(String login, String email, String token, List<dynamic> flowers) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'login': login, 'email': email, 'flowers': flowers}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final updated = User(
        username: json['login'],
        email: json['email'],
        token: token,
        flowers: json['flowers']
      );
      await _storage.saveUser(updated);
      return updated;
    } else {
      throw AuthException(jsonDecode(response.body)['reason'] ?? 'Ошибка обновления данных');
    }
  }
}
