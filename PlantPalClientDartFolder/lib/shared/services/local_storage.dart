import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorage {
  static const _key = 'plantpal_user';
  Future<void> saveUser(User u) async {
    final p = await SharedPreferences.getInstance();
    p.setString(_key, jsonEncode(u.toJson()));
  }
  Future<User?> getUser() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    return s == null ? null : User.fromJson(jsonDecode(s));
  }
  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    p.remove(_key);
  }
}
