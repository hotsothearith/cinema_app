import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/bookings/bookings_page.dart';
import 'features/profile/profile_page.dart';
import 'features/home/home_nav.dart';
import 'features/auth/login_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final tabs = [
      const HomeNav(),
      const BookingsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.25)),
              ),
              child: NavigationBar(
                height: 64,
                backgroundColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.20),
        selectedIndex: _index,
        onDestinationSelected: (i) {
          // If not logged in, protect Bookings/Profile
          if ((i == 1 || i == 2) && !auth.isLoggedIn) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage()));
            return;
          }
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
