// lib/features/auth/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/auth_service.dart';

enum AuthStatus { init, loading, auth, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? message;
  AuthState({required this.status, this.user, this.message});
}

class AuthController extends StateNotifier<AuthState> {
  final _svc = AuthService();
  AuthController() : super(AuthState(status: AuthStatus.init)) {
    _check();
  }
  Future<void> _check() async {
    final u = await _svc.getCurrent();
    if (u != null) state = AuthState(status: AuthStatus.auth, user: u);
  }
  Future<void> login(String u, String p) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final usr = await _svc.login(u, p);
      state = AuthState(status: AuthStatus.auth, user: usr);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
    }
  }
  Future<void> register(String u, String p, String m) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final usr = await _svc.register(u, p, m);
      state = AuthState(status: AuthStatus.auth, user: usr);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
    }
  }
  Future<bool> check(String u, String p, String m) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      return await _svc.check(u, p, m);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
      return false;
    }
  }
  Future<void> logout() async {
    await _svc.logout();
    state = AuthState(status: AuthStatus.init);
  }

  Future<void> changeName(String newName) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final usr = await _svc.changeUsername(newName);
      state = AuthState(status: AuthStatus.auth, user: usr);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final usr = await _svc.changePassword(oldPass, newPass);
      state = AuthState(status: AuthStatus.auth, user: usr);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
    }
  }

  Future<void> changeEmail(String newEmail) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      final usr = await _svc.changeEmail(newEmail);
      state = AuthState(status: AuthStatus.auth, user: usr);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, message: (e as AuthException).message);
    }
  }
}

final authController = StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(),
);
