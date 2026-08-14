import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

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

class AdminBookingListScreen extends StatelessWidget {
  final String title;
  final List<BookingModel> bookings;

  const AdminBookingListScreen({super.key, required this.title, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: bookings.isEmpty
          ? const Center(child: Text('Nothing here yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: _statusColor(b.status), radius: 6),
                    title: Text('${b.customerName} → ${b.professionalName}'),
                    subtitle: Text('${b.tradeName} · ${b.date} ${b.time}\n${b.address}'),
                    isThreeLine: true,
                    trailing: Text(
                      b.status[0].toUpperCase() + b.status.substring(1),
                      style: TextStyle(color: _statusColor(b.status), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}