import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_data_provider.dart';
import 'provider_detail_screen.dart';

class ManageProvidersScreen extends StatelessWidget {
  const ManageProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pending = auth.pendingProviders;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Providers')),
      body: pending.isEmpty
          ? const Center(child: Text('No pending applications'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pending.length,
              itemBuilder: (context, i) {
                final p = pending[i];
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(p.email),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProviderDetailScreen(provider: p)),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Approve',
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () async {
                            await auth.setProviderStatus(p.id, 'approved');
                            if (context.mounted) {
                              await context.read<BookingDataProvider>().fetchProfessionals();
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Reject',
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => auth.setProviderStatus(p.id, 'rejected'),
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