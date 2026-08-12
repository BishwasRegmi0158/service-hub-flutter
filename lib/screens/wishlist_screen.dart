import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_data_provider.dart';
import '../widgets/professional_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<BookingDataProvider>().wishlist;

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlist.isEmpty
          ? const Center(
              child: Text(
                'No favorites yet.\nTap the heart icon on any professional to save them here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) => ProfessionalCard(professional: wishlist[index]),
            ),
    );
  }
}
