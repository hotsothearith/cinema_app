import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_paths.dart';
import '../../models/booking.dart';

class BookingsProvider extends ChangeNotifier {
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  Future<void> fetchMyBookings() async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.bookings);
      final list = _unwrapList(res.data);
      _bookings = list.map((e) => Booking.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load bookings (login required).';
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> createBooking({
    required int showtimeId,
    required List<int> seatIds,
  }) async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.post(ApiPaths.bookings, data: {
        'showtime_id': showtimeId,
        'seat_ids': seatIds,
      });

      // return raw json for Ticket page
      final body = res.data;
      if (body is Map<String, dynamic>) {
        _error = null;
        return body;
      }
      _error = null;
      return {'data': body};
    } catch (e) {
      _error = 'Booking failed. Seats might be already taken.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  List<Map<String, dynamic>> _unwrapList(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List).whereType<Map<String, dynamic>>().toList();
    }
    if (body is List) return body.whereType<Map<String, dynamic>>().toList();
    return [];
  }
}
