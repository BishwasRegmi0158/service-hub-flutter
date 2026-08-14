import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_data_provider.dart';
import 'admin_provider_list_screen.dart';
import 'admin_booking_list_screen.dart';
import 'manage_providers_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingData = context.watch<BookingDataProvider>();

    final allUsers = auth.allUsers;
    final allBookings = bookingData.allBookings;

    final pendingBookings = allBookings.where((b) => b.status == 'pending').toList();
    final completedBookings = allBookings.where((b) => b.status == 'completed').toList();

    final activeProviders = allUsers
        .where((u) => u.role == 'provider' && u.providerStatus == 'approved' && u.isActive)
        .toList();
    final allProviders = allUsers.where((u) => u.role == 'provider').toList();

    final totalCustomers = allUsers.where((u) => u.role == 'user').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () => bookingData.fetchProfessionals(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionLabel('Bookings'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: 'Total Bookings',
                  value: allBookings.length.toString(),
                  icon: Icons.event_note_outlined,
                  color: const Color(0xFF2563EB),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminBookingListScreen(title: 'All Bookings', bookings: allBookings),
                    ),
                  ),
                ),
                _StatCard(
                  label: 'Pending Bookings',
                  value: pendingBookings.length.toString(),
                  icon: Icons.hourglass_top_outlined,
                  color: Colors.amber.shade800,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminBookingListScreen(title: 'Pending Bookings', bookings: pendingBookings),
                    ),
                  ),
                ),
                _StatCard(
                  label: 'Completed',
                  value: completedBookings.length.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminBookingListScreen(title: 'Completed Bookings', bookings: completedBookings),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Providers'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: 'Pending Approvals',
                  value: auth.pendingProviders.length.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: Colors.deepOrange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageProvidersScreen()),
                  ),
                ),
                _StatCard(
                  label: 'Active Providers',
                  value: activeProviders.length.toString(),
                  icon: Icons.verified_outlined,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminProviderListScreen(title: 'Active Providers', providers: activeProviders),
                    ),
                  ),
                ),
                _StatCard(
                  label: 'Total Providers',
                  value: allProviders.length.toString(),
                  icon: Icons.handyman_outlined,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminProviderListScreen(title: 'All Providers', providers: allProviders),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Users'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  label: 'Total Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people_outline,
                  color: Colors.blueGrey,
                ),
                _StatCard(
                  label: 'Total Accounts',
                  value: allUsers.length.toString(),
                  icon: Icons.groups_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Spacer(),
                if (onTap != null) const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
              ],
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}