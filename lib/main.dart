import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_data_provider.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage boxes:
  //   bookings      -> every booking made (guest or account-linked)
  //   users         -> locally created accounts (email -> user map)
  //   session       -> which account (if any) is currently logged in
  //   wishlist      -> saved professional ids, so favorites survive restart
  //   professionals -> provider-created listings (id -> professional map),
  //                    separate from the API-fetched demo professionals
  await Hive.initFlutter();
  await Hive.openBox('bookings');
  await Hive.openBox('users');
  await Hive.openBox('session');
  await Hive.openBox('wishlist');
  await Hive.openBox('professionals');

  final authProvider = AuthProvider();
  await authProvider.loadSession();
  await authProvider.seedAdminAccount(); // creates admin@servicehub.app / admin123 on first run

  runApp(ServiceHubApp(authProvider: authProvider));
}

class ServiceHubApp extends StatelessWidget {
  final AuthProvider authProvider;
  const ServiceHubApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => BookingDataProvider()),
      ],
      child: MaterialApp(
        title: 'ServiceHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2563EB),
          useMaterial3: true,
        ),
        // No login gate — MainShell is always the home screen. Signing in
        // only happens if the person chooses to, from the Profile tab.
        home: const MainShell(),
      ),
    );
  }
}