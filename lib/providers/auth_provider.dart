// AuthProvider
// A simple LOCAL authentication system — no backend server. Accounts are
// stored on-device in Hive. Login is NEVER required to use the app —
// this just tracks whether someone happens to be signed in right now,
// so bookings can be tagged with a userId when available.

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Box get _usersBox => Hive.box('users');
  Box get _sessionBox => Hive.box('session');

  Future<void> loadSession() async {
    final savedEmail = _sessionBox.get('currentUserEmail');
    if (savedEmail != null) {
      final userMap = _usersBox.get(savedEmail);
      if (userMap != null) {
        _currentUser = UserModel.fromMap(userMap);
        notifyListeners();
      }
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usersBox.containsKey(normalizedEmail)) {
      return 'An account with this email already exists.';
    }

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
      password: password, // plain text is fine for a class project only
    );

    await _usersBox.put(normalizedEmail, user.toMap());
    await _sessionBox.put('currentUserEmail', normalizedEmail);

    _currentUser = user;
    notifyListeners();
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final userMap = _usersBox.get(normalizedEmail);

    if (userMap == null) {
      return 'No account found with this email.';
    }

    final user = UserModel.fromMap(userMap);
    if (user.password != password) {
      return 'Incorrect password.';
    }

    await _sessionBox.put('currentUserEmail', normalizedEmail);
    _currentUser = user;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _sessionBox.delete('currentUserEmail');
    _currentUser = null;
    notifyListeners();
  }
}
