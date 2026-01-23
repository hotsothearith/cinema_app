import 'package:flutter/material.dart';
import 'core/api/api_client.dart';
import 'core/ui/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/bookings/bookings_provider.dart';
import 'features/movies/movies_provider.dart';
import 'features/showtimes/showtimes_provider.dart';
import 'app_shell.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => ShowtimesProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
      ],
      child: const CinemaApp(),
    ),
  );
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Booking',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const AppShell(),
      themeMode: ThemeMode.dark,
    );
  }
}
