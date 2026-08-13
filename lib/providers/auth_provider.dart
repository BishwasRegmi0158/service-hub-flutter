// AuthProvider
// A simple LOCAL authentication system — no backend server. Accounts are
// stored on-device in Hive. Login is NEVER required to use the app as a
// regular user — this just tracks whether someone happens to be signed
// in right now, so bookings can be tagged with a userId when available.
//
// NEW: three roles.
//   'user'     — same as before, browsing/booking is always optional login.
//   'provider' — signs up with a trade + rate, creates their own
//                Professional listing (stored in the 'professionals' box),
//                and cannot log in until an admin approves them.
//   'admin'    — never created through signup. Seeded once via
//                seedAdminAccount(), called from main.dart.

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/professional.dart';
import '../models/trade.dart';

class SignupResult {
  final bool success;
  final String? error;
  final bool needsApproval;
  const SignupResult({required this.success, this.error, this.needsApproval = false});
}

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Box get _usersBox => Hive.box('users');
  Box get _sessionBox => Hive.box('session');
  Box get _professionalsBox => Hive.box('professionals');

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

  // Call once from main.dart after Hive.openBox('users') so there's
  // always at least one way into the admin screens.
  Future<void> seedAdminAccount() async {
    const adminEmail = 'admin@servicehub.app';
    if (!_usersBox.containsKey(adminEmail)) {
      final admin = UserModel(
        id: 'admin-0',
        name: 'Admin',
        email: adminEmail,
        password: 'admin123', // change this before submitting/demoing
        role: 'admin',
      );
      await _usersBox.put(adminEmail, admin.toMap());
    }
  }

  // ---------- Signup ----------

  Future<SignupResult> signup({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    int? tradeId,
    double? pricePerHour,
    String? bio,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_usersBox.containsKey(normalizedEmail)) {
      return const SignupResult(success: false, error: 'An account with this email already exists.');
    }

    final isProvider = role == 'provider';

    if (isProvider && (tradeId == null || pricePerHour == null)) {
      return const SignupResult(success: false, error: 'Please select a trade and hourly rate.');
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    String? professionalId;

    if (isProvider) {
      professionalId = 'prov-$userId';
      final nameParts = name.trim().split(' ');
      final professional = Professional(
        id: professionalId,
        firstName: nameParts.first,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        photoUrl: '',
        email: normalizedEmail,
        phone: '',
        city: '',
        state: '',
        trade: Trades.byId(tradeId!),
        rating: 0,
        pricePerHour: pricePerHour!,
        experienceYears: 0,
        bio: bio ?? '',
        ownerUserId: userId,
        isApproved: false, // hidden from the public catalog until admin approves
      );
      await _professionalsBox.put(professionalId, professional.toMap());
    }

    final user = UserModel(
      id: userId,
      name: name.trim(),
      email: normalizedEmail,
      password: password, // plain text is fine for a class project only
      role: role,
      providerStatus: isProvider ? 'pending' : 'none',
      professionalId: professionalId,
    );

    await _usersBox.put(normalizedEmail, user.toMap());

    if (isProvider) {
      // Don't log them in — they need to wait for admin approval first.
      return const SignupResult(success: true, needsApproval: true);
    }

    await _sessionBox.put('currentUserEmail', normalizedEmail);
    _currentUser = user;
    notifyListeners();
    return const SignupResult(success: true);
  }

  // ---------- Login ----------

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
    if (!user.isActive) {
      return 'This account has been deactivated. Contact an admin.';
    }
    if (user.role == 'provider' && user.providerStatus == 'pending') {
      return 'Your provider account is still awaiting admin approval.';
    }
    if (user.role == 'provider' && user.providerStatus == 'rejected') {
      return 'Your provider application was not approved.';
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

  // ---------- Admin ----------

  List<UserModel> get allUsers => _usersBox.values.map((m) => UserModel.fromMap(m)).toList();

  List<UserModel> get pendingProviders =>
      allUsers.where((u) => u.role == 'provider' && u.providerStatus == 'pending').toList();

  List<UserModel> get regularUsers => allUsers.where((u) => u.role == 'user').toList();

  dynamic _keyForUserId(String userId) {
    for (final key in _usersBox.keys) {
      final map = _usersBox.get(key);
      if (map != null && map['id'] == userId) return key;
    }
    return null;
  }

  // status: 'approved' | 'rejected'
  Future<void> setProviderStatus(String userId, String status) async {
    final key = _keyForUserId(userId);
    if (key == null) return;

    final user = UserModel.fromMap(_usersBox.get(key));
    final updated = user.copyWith(providerStatus: status);
    await _usersBox.put(key, updated.toMap());

    if (updated.professionalId != null && _professionalsBox.containsKey(updated.professionalId)) {
      final profMap = Map<dynamic, dynamic>.from(_professionalsBox.get(updated.professionalId));
      profMap['isApproved'] = status == 'approved';
      await _professionalsBox.put(updated.professionalId, profMap);
    }

    if (_currentUser?.id == userId) {
      _currentUser = updated;
    }
    notifyListeners();
  }

  Future<void> setUserActive(String userId, bool isActive) async {
    final key = _keyForUserId(userId);
    if (key == null) return;

    final user = UserModel.fromMap(_usersBox.get(key));
    await _usersBox.put(key, user.copyWith(isActive: isActive).toMap());

    if (_currentUser?.id == userId) {
      _currentUser = _currentUser!.copyWith(isActive: isActive);
    }
    notifyListeners();
  }
}
