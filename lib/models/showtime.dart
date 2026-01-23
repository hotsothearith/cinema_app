import 'cinema.dart';

class Showtime {
  final int id;
  final int movieId;
  final int cinemaId;
  final DateTime startsAt;
  final double? price;
  final Cinema? cinema; // if backend returns relationship

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.startsAt,
    this.price,
    this.cinema,
  });

  static Showtime fromJson(Map<String, dynamic> j) {
    int toInt(dynamic x) => x is num ? x.toInt() : int.tryParse(x.toString()) ?? 0;
    double? toDouble(dynamic x) => x == null ? null : (x is num ? x.toDouble() : double.tryParse(x.toString()));
    DateTime parseDate(dynamic x) => DateTime.parse(x.toString());

    final cinemaJson = j['cinema'];
    return Showtime(
      id: toInt(j['id']),
      movieId: toInt(j['movie_id'] ?? j['movieId']),
      cinemaId: toInt(j['cinema_id'] ?? j['cinemaId']),
      startsAt: parseDate(j['starts_at'] ?? j['startsAt']),
      price: toDouble(j['price'] ?? j['ticket_price']),
      cinema: cinemaJson is Map<String, dynamic> ? Cinema.fromJson(cinemaJson) : null,
    );
  }
}
