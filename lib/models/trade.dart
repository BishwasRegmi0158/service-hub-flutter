// Trade model
// The public API we use (RandomUser.me) gives us real people/profiles,
// but has no idea about "trades" like painter/electrician/plumber —
// that's not something any free public API tracks. So the list of trades
// itself is defined locally here, and each fetched professional gets
// assigned one of these trades (see api_service.dart). This is a common,
// legitimate pattern: combine a public API (for realistic profile data)
// with domain-specific data you define yourself.

import 'package:flutter/material.dart';

class Trade {
  final int id;
  final String name;
  final IconData icon;

  const Trade({required this.id, required this.name, required this.icon});
}

class Trades {
  static const List<Trade> all = [
    Trade(id: 1, name: 'Painter', icon: Icons.format_paint_outlined),
    Trade(id: 2, name: 'Electrician', icon: Icons.electrical_services_outlined),
    Trade(id: 3, name: 'Plumber', icon: Icons.plumbing_outlined),
    Trade(id: 4, name: 'Carpenter', icon: Icons.handyman_outlined),
    Trade(id: 5, name: 'Mason', icon: Icons.foundation_outlined),
    Trade(id: 6, name: 'AC Technician', icon: Icons.ac_unit_outlined),
    Trade(id: 7, name: 'Gardener', icon: Icons.grass_outlined),
    Trade(id: 8, name: 'House Cleaner', icon: Icons.cleaning_services_outlined),
    Trade(id: 9, name: 'Locksmith', icon: Icons.key_outlined),
    Trade(id: 10, name: 'Appliance Repair', icon: Icons.build_circle_outlined),
  ];

  static Trade byId(int id) => all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
