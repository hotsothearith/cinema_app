import 'showtime.dart';

class Booking {
  final int id;
  final int showtimeId;
  final List<String> seatNumbers;
  final DateTime? createdAt;
  final Showtime? showtime;

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
      try {
        return DateTime.parse(x.toString());
      } catch (_) {
        return null;
      }
    }

    // ✅ handle: seat_numbers, seat_codes, seats
    final seatsRaw = j['seat_numbers'] ?? j['seat_codes'] ?? j['seats'];

    final List<String> seatNumbers = [];

    if (seatsRaw is List) {
      for (final item in seatsRaw) {
        // Case 1: ["B1","B2"]
        if (item is String || item is num) {
          seatNumbers.add(item.toString());
          continue;
        }

        // ✅ Case 2: [{seat_number:"B1", ...}, {...}]
        if (item is Map<String, dynamic>) {
          final label =
              item['seat_number'] ?? item['seat_code'] ?? item['number'] ?? item['code'];
          if (label != null) seatNumbers.add(label.toString());
        }
      }
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
