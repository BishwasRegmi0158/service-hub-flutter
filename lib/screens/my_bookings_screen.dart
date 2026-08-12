import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.id;
    final box = Hive.box('bookings');

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box b, _) {
          final keys = b.keys.where((key) {
            final booking = BookingModel.fromMap(b.get(key));
            return booking.userId == currentUserId;
          }).toList();

          if (keys.isEmpty) {
            return Center(
              child: Text(
                currentUserId != null
                    ? 'No bookings yet on this account.'
                    : 'No guest bookings yet.\nBook a professional to see it here.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final booking = BookingModel.fromMap(b.get(key));

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(backgroundImage: NetworkImage(booking.professionalPhoto)),
                  title: Text(
                    '${booking.professionalName} • ${booking.tradeName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booked by: ${booking.customerName}'),
                      Text('${booking.date} at ${booking.time}'),
                      Text(booking.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('\$${booking.pricePerHour.toStringAsFixed(0)}/hr'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => b.delete(key),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
