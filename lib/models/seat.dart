class Seat {
  final int id;
  final String number; // seat_number / seat_code
  final bool isAvailable;

  Seat({required this.id, required this.number, required this.isAvailable});

  static Seat fromJson(Map<String, dynamic> j) {
    int toInt(dynamic x) => x is num ? x.toInt() : int.tryParse(x.toString()) ?? 0;

    final number = (j['seat_number'] ?? j['seat_code'] ?? j['code'] ?? j['number'] ?? '').toString();

    // support many backends: is_available, is_booked, status
    bool avail = true;
    if (j.containsKey('is_available')) avail = j['is_available'] == true || j['is_available'] == 1;
    if (j.containsKey('is_booked')) avail = !(j['is_booked'] == true || j['is_booked'] == 1);
    if (j.containsKey('status')) {
      final s = j['status']?.toString().toLowerCase();
      if (s == 'booked' || s == 'reserved' || s == 'taken') avail = false;
    }

    return Seat(
      id: toInt(j['id']),
      number: number,
      isAvailable: avail,
    );
  }
}
