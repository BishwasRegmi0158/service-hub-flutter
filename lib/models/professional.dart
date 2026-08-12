// Professional model
// Represents a bookable home-service professional. Identity fields
// (name, photo, email, phone, city) come straight from the public
// RandomUser.me API. Trade, price, rating, experience, and bio are
// generated locally at fetch time (see ApiService) since no public API
// tracks "how much does this electrician charge."

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
  });

  String get fullName => '$firstName $lastName';
  String get location => '$city, $state';
}
