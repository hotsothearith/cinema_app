import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_paths.dart';
import '../../models/showtime.dart';

class ShowtimesProvider extends ChangeNotifier {
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Showtime> _all = [];
  List<Showtime> get all => _all;

  Future<void> fetchShowtimes() async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.showtimes);
      final list = _unwrapList(res.data);
      _all = list.map((e) => Showtime.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load showtimes.';
    } finally {
      _setLoading(false);
    }
  }

  List<Showtime> forMovie(int movieId) {
    final filtered = _all.where((s) => s.movieId == movieId).toList();
    filtered.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return filtered;
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  List<Map<String, dynamic>> _unwrapList(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List).whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic> &&
        body['data'] is Map<String, dynamic> &&
        (body['data'] as Map<String, dynamic>)['data'] is List) {
      final inner = (body['data'] as Map<String, dynamic>)['data'] as List;
      return inner.whereType<Map<String, dynamic>>().toList();
    }

    if (body is List) return body.whereType<Map<String, dynamic>>().toList();
    return [];
  }
}
