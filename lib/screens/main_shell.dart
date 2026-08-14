import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicehub_app/screens/admin/admin_dashboard_screen.dart';
import 'package:servicehub_app/screens/my_services_screen.dart';
import 'package:servicehub_app/screens/provider_requests_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_data_provider.dart';
import 'home_screen.dart';
import 'trades_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';
import 'admin/manage_providers_screen.dart';
import 'admin/manage_users_screen.dart';

// Top-level router: picks a shell based on the logged-in account's role.
// Guests (no logged-in user) and role == 'user' both get the normal
// browsing/booking shell — login stays fully optional for that path.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentUser?.role ?? 'user';

    switch (role) {
      case 'admin':
        return const _AdminShell();
      case 'provider':
        return const _ProviderShell();
      default:
        return const _UserShell();
    }
  }
}

// ---------- Regular user / guest shell (unchanged from before) ----------

class _UserShell extends StatefulWidget {
  const _UserShell();

  @override
  State<_UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<_UserShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<BookingDataProvider>();
      provider.fetchProfessionals().then((_) => provider.restoreWishlistFromStorage());
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TradesScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const WishlistScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<BookingDataProvider>().cart.length;

    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Trades'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: 'Queue',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Wishlist'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------- Service provider shell ----------

class _ProviderShell extends StatefulWidget {
  const _ProviderShell();

  @override
  State<_ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<_ProviderShell> {
  int _currentIndex = 0;

  static const _pages = [
    ProviderRequestsScreen(),
    MyServicesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), activeIcon: Icon(Icons.inbox), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'My Listing'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------- Admin shell ----------
class _AdminShell extends StatefulWidget {
  const _AdminShell();

  @override
  State<_AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<_AdminShell> {
  int _currentIndex = 0;

  static const _pages = [
    AdminDashboardScreen(),
    ManageProvidersScreen(),
    ManageUsersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions_outlined), activeIcon: Icon(Icons.pending_actions), label: 'Providers'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}