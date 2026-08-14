import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_data_provider.dart';

Color _statusColor(String status) {
  switch (status) {
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'cancelled':
      return Colors.grey;
    case 'completed':
      return Colors.blue;
    default:
      return Colors.amber;
  }
}

class ProviderRequestsScreen extends StatelessWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingData = context.watch<BookingDataProvider>();
    final userId = auth.currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('No listing found for this account.')),
      );
    }

    final myProfessionals = bookingData.professionalsForOwner(userId);
    if (myProfessionals.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No listing found for this account.')),
      );
    }

    final ids = myProfessionals.map((p) => p.id).toList();
    final requests = bookingData.bookingsForProfessionals(ids);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: requests.isEmpty
          ? const Center(child: Text('No booking requests yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: requests.length,
              itemBuilder: (context, i) {
                final b = requests[i];
                return Card(
                  child: ListTile(
                    title: Text('${b.customerName} — ${b.date} ${b.time}'),
                    subtitle: Text(
                      '${b.professionalName}\n${b.address}\n${b.status[0].toUpperCase()}${b.status.substring(1)}',
                    ),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(b.status),
                      radius: 6,
                    ),
                    trailing: b.status == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => bookingData.updateBookingStatus(b.id, 'approved'),
                                child: const Text('Approve'),
                              ),
                              TextButton(
                                onPressed: () => bookingData.updateBookingStatus(b.id, 'rejected'),
                                child: const Text('Cancel'),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}