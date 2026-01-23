import 'package:flutter/material.dart';
import 'pages/movie_list_page.dart';
import 'pages/movie_detail_page.dart';
import 'pages/showtimes_page.dart';
import 'pages/seats_page.dart';
import 'pages/checkout_page.dart';
import 'pages/ticket_page.dart';

class HomeNav extends StatelessWidget {
  const HomeNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/movies',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/movies':
            return MaterialPageRoute(builder: (_) => const MovieListPage());

          case '/movie-detail':
            final movieId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: movieId));

          case '/showtimes':
            final movieId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => ShowtimesPage(movieId: movieId));

          case '/seats':
            final showtimeId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => SeatsPage(showtimeId: showtimeId));

          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CheckoutPage(
                showtimeId: args['showtimeId'] as int,
                seatIds: List<int>.from(args['seatIds'] as List),
                seatLabels: List<String>.from(args['seatLabels'] as List),
              ),
            );

          case '/ticket':
            final bookingJson = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => TicketPage(bookingJson: bookingJson));

          default:
            return MaterialPageRoute(builder: (_) => const MovieListPage());
        }
      },
    );
  }
}
