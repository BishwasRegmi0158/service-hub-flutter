// User model
// Represents a locally-created account. No real backend — this is a
// simple local sign up / login system stored in Hive.
//
// role:            'user' | 'provider' | 'admin'
// providerStatus:  'none' | 'pending' | 'approved' | 'rejected'
//                  (only meaningful when role == 'provider')
// professionalId:  when role == 'provider', links this account to its
//                  Professional listing in the 'professionals' box.
// isActive:        admin can deactivate an account without deleting it.

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String providerStatus;
  final String? professionalId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
    this.providerStatus = 'none',
    this.professionalId,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isProvider => role == 'provider';
  bool get isApprovedProvider => role == 'provider' && providerStatus == 'approved';
  bool get isPendingProvider => role == 'provider' && providerStatus == 'pending';

  UserModel copyWith({
    String? name,
    String? password,
    String? role,
    String? providerStatus,
    String? professionalId,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      password: password ?? this.password,
      role: role ?? this.role,
      providerStatus: providerStatus ?? this.providerStatus,
      professionalId: professionalId ?? this.professionalId,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'providerStatus': providerStatus,
      'professionalId': professionalId,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'user',
      providerStatus: map['providerStatus'] ?? 'none',
      professionalId: map['professionalId'],
      isActive: map['isActive'] ?? true,
    );
  }
}
