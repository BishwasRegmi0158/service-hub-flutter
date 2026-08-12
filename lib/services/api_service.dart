// API Service
// Uses RandomUser.me (https://randomuser.me/api) — a free, public,
// no-key-needed API that returns realistic random people (name, photo,
// email, phone, location). We treat each person as a "professional" and
// assign them a trade (painter, electrician, etc.), price, rating, and
// bio locally, since no public API tracks home-service pricing data.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/professional.dart';
import '../models/trade.dart';

class ApiService {
  static const String baseUrl = 'https://randomuser.me/api';

  final _bioTemplates = [
    'Reliable {trade} with {years} years of hands-on experience serving local homes and businesses.',
    'Skilled {trade} known for quality work, punctuality, and fair pricing.',
    'Professional {trade} offering same-day service and a satisfaction guarantee.',
    'Experienced {trade} specializing in both repairs and new installations.',
  ];

  // Fetches `count` professionals and assigns each a trade so the trades
  // are evenly distributed across the results.
  Future<List<Professional>> getProfessionals({int count = 40}) async {
    final response = await http.get(Uri.parse('$baseUrl/?results=$count&nat=us,gb,ca'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load professionals (status ${response.statusCode})');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'] ?? [];

    final professionals = <Professional>[];

    for (int i = 0; i < results.length; i++) {
      final person = results[i];
      final trade = Trades.all[i % Trades.all.length];

      // Use a seeded Random (based on index) so a given person always
      // gets the same price/rating/experience within one fetch, instead
      // of jumping around visually if the widget rebuilds.
      final rand = Random(i + 7);
      final rating = 3.6 + rand.nextDouble() * 1.4; // 3.6 - 5.0
      final price = 15 + rand.nextInt(46).toDouble(); // $15 - $60/hr
      final years = 1 + rand.nextInt(19); // 1 - 19 years

      final bioTemplate = _bioTemplates[i % _bioTemplates.length];
      final bio = bioTemplate
          .replaceAll('{trade}', trade.name.toLowerCase())
          .replaceAll('{years}', years.toString());

      professionals.add(Professional(
        id: person['login']?['uuid'] ?? i.toString(),
        firstName: person['name']?['first'] ?? 'Professional',
        lastName: person['name']?['last'] ?? '',
        photoUrl: person['picture']?['large'] ?? '',
        email: person['email'] ?? '',
        phone: person['phone'] ?? '',
        city: person['location']?['city'] ?? 'Unknown',
        state: person['location']?['state'] ?? '',
        trade: trade,
        rating: double.parse(rating.toStringAsFixed(1)),
        pricePerHour: price,
        experienceYears: years,
        bio: bio,
      ));
    }

    return professionals;
  }
}
