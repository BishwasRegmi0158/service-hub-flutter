import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'provider_detail_screen.dart';

class AdminProviderListScreen extends StatelessWidget {
  final String title;
  final List<UserModel> providers;

  const AdminProviderListScreen({super.key, required this.title, required this.providers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: providers.isEmpty
          ? const Center(child: Text('Nothing here yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: providers.length,
              itemBuilder: (context, i) {
                final p = providers[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.handyman, size: 18)),
                    title: Text(p.name),
                    subtitle: Text(p.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProviderDetailScreen(provider: p)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}