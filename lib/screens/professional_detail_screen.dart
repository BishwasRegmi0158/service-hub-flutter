import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/professional.dart';
import '../providers/booking_data_provider.dart';
import '../utils/image_helper.dart';
import 'booking_form_screen.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  final Professional professional;
  const ProfessionalDetailScreen({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingDataProvider>();
    final isWishlisted = provider.isInWishlist(professional.id);
    final isInCart = provider.isInCart(professional.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(professional.fullName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : null,
            ),
            onPressed: () => provider.toggleWishlist(professional),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            professionalPhotoWidget(professional.photoUrl, width: double.infinity, height: 260),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(professional.trade.icon, size: 16),
                        label: Text(professional.trade.name),
                      ),
                      Chip(label: Text('${professional.experienceYears} yrs experience')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(' ${professional.rating}'),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      Text(' ${professional.location}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${professional.pricePerHour.toStringAsFixed(0)} / hour',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple[700]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isInCart
                              ? null
                              : () {
                                  provider.addToCart(professional);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to booking queue'),
                                      duration: Duration(milliseconds: 900),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text(isInCart ? 'In Queue' : 'Add to Queue'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingFormScreen(professionals: [professional]),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_available_outlined),
                          label: const Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(professional.bio, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 16),
                  const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text(professional.email, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(professional.phone),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}