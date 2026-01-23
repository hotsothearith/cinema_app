import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_paths.dart';
import '../../models/seat.dart';

class SeatsProvider extends ChangeNotifier {
  final int showtimeId;
  SeatsProvider(this.showtimeId);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Seat> _seats = [];
  List<Seat> get seats => _seats;

  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => _selectedIds;

  List<String> get selectedLabels {
    final map = {for (final s in _seats) s.id: s.number};
    return _selectedIds.map((id) => map[id] ?? '#$id').toList();
  }

  Future<void> fetchSeats() async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.seatsByShowtime(showtimeId));
      final list = _unwrapList(res.data);
      _seats = list.map((e) => Seat.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load seats.';
    } finally {
      _setLoading(false);
    }
  }

  void toggleSeat(Seat seat) {
    if (!seat.isAvailable) return;
    if (_selectedIds.contains(seat.id)) {
      _selectedIds.remove(seat.id);
    } else {
      _selectedIds.add(seat.id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
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
