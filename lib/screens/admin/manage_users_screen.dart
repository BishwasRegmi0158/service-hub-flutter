import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final users = auth.regularUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: users.isEmpty
          ? const Center(child: Text('No users yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, i) {
                final u = users[i];
                return Card(
                  child: ListTile(
                    title: Text(u.name),
                    subtitle: Text(u.email),
                    trailing: Switch(
                      value: u.isActive,
                      onChanged: (value) => auth.setUserActive(u.id, value),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
