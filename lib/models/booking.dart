import 'showtime.dart';

class Booking {
  final int id;
  final int showtimeId;
  final List<String> seatNumbers;
  final DateTime? createdAt;
  final Showtime? showtime; // optional if backend returns nested

  Booking({
    required this.id,
    required this.showtimeId,
    required this.seatNumbers,
    this.createdAt,
    this.showtime,
  });

  static Booking fromJson(Map<String, dynamic> j) {
    int toInt(dynamic x) => x is num ? x.toInt() : int.tryParse(x.toString()) ?? 0;
    DateTime? toDate(dynamic x) {
      if (x == null) return null;
      try { return DateTime.parse(x.toString()); } catch (_) { return null; }
    }

    final seats = (j['seat_numbers'] ?? j['seat_codes'] ?? j['seats']) as dynamic;
    List<String> seatNumbers = [];
    if (seats is List) {
      seatNumbers = seats.map((e) => e.toString()).toList();
    }

    final showtimeJson = j['showtime'];
    return Booking(
      id: toInt(j['id']),
      showtimeId: toInt(j['showtime_id'] ?? j['showtimeId']),
      seatNumbers: seatNumbers,
      createdAt: toDate(j['created_at'] ?? j['createdAt']),
      showtime: showtimeJson is Map<String, dynamic> ? Showtime.fromJson(showtimeJson) : null,
    );
  }
}
