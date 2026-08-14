import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicehub_app/utils/image_helper.dart';
import '../models/professional.dart';
import '../providers/booking_data_provider.dart';
import '../screens/professional_detail_screen.dart';

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  const ProfessionalCard({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingDataProvider>();
    final isWishlisted = provider.isInWishlist(professional.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfessionalDetailScreen(professional: professional),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                 professionalPhotoWidget(professional.photoUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => provider.toggleWishlist(professional),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(professional.trade.icon, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            professional.trade.name,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      Text(' ${professional.rating}', style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(
                        '\$${professional.pricePerHour.toStringAsFixed(0)}/hr',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                      ),
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
