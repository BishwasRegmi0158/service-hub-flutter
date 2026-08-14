import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

Color _roleColor(String role) {
  switch (role) {
    case 'admin':
      return Colors.purple;
    case 'provider':
      return Colors.teal;
    default:
      return Colors.blueGrey;
  }
}

String _roleLabel(UserModel u) {
  if (u.role == 'admin') return 'Admin';
  if (u.role == 'provider') return 'Provider · ${u.providerStatus}';
  return 'User';
}

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  Future<void> _confirmPromote(BuildContext context, String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Promote to Admin?'),
        content: Text('$name will gain full admin access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Promote')),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AuthProvider>().promoteToAdmin(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final accounts = auth.allUsers.where((u) => u.id != auth.currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('All Accounts')),
      body: accounts.isEmpty
          ? const Center(child: Text('No accounts yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final u = accounts[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _roleColor(u.role).withValues(alpha: 0.15),
                            child: Icon(
                              u.role == 'admin'
                                  ? Icons.admin_panel_settings
                                  : u.role == 'provider'
                                      ? Icons.handyman
                                      : Icons.person,
                              color: _roleColor(u.role),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _roleColor(u.role).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _roleLabel(u),
                              style: TextStyle(fontSize: 11.5, color: _roleColor(u.role), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          if (u.role != 'admin')
                            IconButton(
                              tooltip: 'Promote to Admin',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              onPressed: () => _confirmPromote(context, u.id, u.name),
                            ),
                          Switch(
                            value: u.isActive,
                            onChanged: (value) => auth.setUserActive(u.id, value),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}