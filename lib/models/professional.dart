// Professional model
// Two sources of Professional now exist:
//   1. API-seeded (RandomUser.me) — ownerUserId is null, isApproved is
//      always true, these are your existing demo catalog entries.
//   2. Provider-created — a real signed-up service provider makes their
//      own listing at signup. ownerUserId links back to their UserModel.
//      isApproved starts false and only flips to true once an admin
//      approves them (see AuthProvider.setProviderStatus).
//
// toMap/fromMap are new — needed so provider-created listings can be
// persisted in the 'professionals' Hive box (API ones are never saved,
// same as before — they're re-fetched fresh each launch).

import 'trade.dart';

class Professional {
  final String id;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String email;
  final String phone;
  final String city;
  final String state;
  final Trade trade;
  final double rating;
  final double pricePerHour;
  final int experienceYears;
  final String bio;
  final String? ownerUserId;
  final bool isApproved;

  Professional({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.email,
    required this.phone,
    required this.city,
    required this.state,
    required this.trade,
    required this.rating,
    required this.pricePerHour,
    required this.experienceYears,
    required this.bio,
    this.ownerUserId,
    this.isApproved = true,
  });

  String get fullName => '$firstName $lastName';
  String get location => '$city, $state';

 Professional copyWith({
    double? pricePerHour,
    String? bio,
    int? experienceYears,
    bool? isApproved,
    String? photoUrl,
    Trade? trade,
  }) {
    return Professional(
      id: id,
      firstName: firstName,
      lastName: lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email,
      phone: phone,
      city: city,
      state: state,
      trade: trade ?? this.trade,
      rating: rating,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      ownerUserId: ownerUserId,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'email': email,
      'phone': phone,
      'city': city,
      'state': state,
      'tradeId': trade.id,
      'rating': rating,
      'pricePerHour': pricePerHour,
      'experienceYears': experienceYears,
      'bio': bio,
      'ownerUserId': ownerUserId,
      'isApproved': isApproved,
    };
  }

  factory Professional.fromMap(Map<dynamic, dynamic> map) {
    return Professional(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      trade: Trades.byId(map['tradeId'] ?? 1),
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      pricePerHour: (map['pricePerHour'] is num) ? (map['pricePerHour'] as num).toDouble() : 0.0,
      experienceYears: map['experienceYears'] ?? 0,
      bio: map['bio'] ?? '',
      ownerUserId: map['ownerUserId'],
      isApproved: map['isApproved'] ?? true,
    );
  }
}
