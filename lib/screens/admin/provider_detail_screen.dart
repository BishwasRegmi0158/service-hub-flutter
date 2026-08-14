import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicehub_app/utils/image_helper.dart';
import '../../models/user_model.dart';
import '../../providers/booking_data_provider.dart';

class ProviderDetailScreen extends StatelessWidget {
  final UserModel provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bookingData = context.watch<BookingDataProvider>();
    final listing = provider.professionalId == null
        ? null
        : bookingData.professionalById(provider.professionalId!);

    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(provider.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(provider.email, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text('Status: ${provider.providerStatus}'),
          const Divider(height: 32),
          if (listing == null)
            const Text('No listing details found for this provider.')
          else ...[
            if (listing.photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: professionalPhotoWidget(listing.photoUrl, height: 180, width: double.infinity),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(avatar: Icon(listing.trade.icon, size: 16), label: Text(listing.trade.name)),
                Chip(label: Text('${listing.experienceYears} yrs experience')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${listing.pricePerHour.toStringAsFixed(0)} / hour',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(listing.bio.isEmpty ? 'No bio provided.' : listing.bio),
          ],
        ],
      ),
    );
  }
}