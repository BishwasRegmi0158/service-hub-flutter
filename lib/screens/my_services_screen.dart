import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicehub_app/utils/image_helper.dart';
import '../../models/professional.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_data_provider.dart';
import 'service_form_screen.dart';

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Professional p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this service?'),
        content: Text('This removes "${p.trade.name} — \$${p.pricePerHour.toStringAsFixed(0)}/hr" permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<BookingDataProvider>().deleteProfessional(p.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingData = context.watch<BookingDataProvider>();
    final userId = auth.currentUser?.id;
    final services = userId == null ? <Professional>[] : bookingData.professionalsForOwner(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceFormScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      body: services.isEmpty
          ? const Center(child: Text('You have no services yet. Tap "Add Service" to create one.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: services.length,
              itemBuilder: (context, i) {
                final p = services[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: professionalImageProvider(p.photoUrl),
                      child: p.photoUrl.isEmpty ? Icon(p.trade.icon) : null,
                    ),
                    title: Text('${p.trade.name} — \$${p.pricePerHour.toStringAsFixed(0)}/hr'),
                    subtitle: Text(
                      p.isApproved ? 'Approved — visible in the app' : 'Pending admin approval',
                      style: TextStyle(color: p.isApproved ? Colors.green : Colors.amber.shade800),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ServiceFormScreen(existing: p)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}