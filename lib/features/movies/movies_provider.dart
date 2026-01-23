import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_paths.dart';
import '../../models/movie.dart';

class MoviesProvider extends ChangeNotifier {
  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  final Map<int, Movie> _cache = {};

  Future<void> fetchMovies() async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.movies);
      final list = _unwrapList(res.data);
      _movies = list.map((e) => Movie.fromJson(e)).toList();
      for (final m in _movies) {
        _cache[m.id] = m;
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load movies. Check API base URL.';
    } finally {
      _setLoading(false);
    }
  }

  Future<Movie?> fetchMovieDetail(int id) async {
    if (_cache.containsKey(id) && (_cache[id]!.description?.isNotEmpty ?? false)) {
      return _cache[id];
    }

    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.movieDetail(id));
      final data = _unwrapData(res.data);
      final movie = Movie.fromJson(data);
      _cache[id] = movie;
      return movie;
    } catch (e) {
      return _cache[id];
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  List<Map<String, dynamic>> _unwrapList(dynamic body) {
    // Case 1: { data: [ ... ] }
    if (body is Map<String, dynamic> && body['data'] is List) {
      return (body['data'] as List).whereType<Map<String, dynamic>>().toList();
    }

    // Case 2: Laravel paginate: { data: { data: [ ... ] } }
    if (body is Map<String, dynamic> &&
        body['data'] is Map<String, dynamic> &&
        (body['data'] as Map<String, dynamic>)['data'] is List) {
      final inner = (body['data'] as Map<String, dynamic>)['data'] as List;
      return inner.whereType<Map<String, dynamic>>().toList();
    }

    // Case 3: raw list
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  Map<String, dynamic> _unwrapData(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    if (body is Map<String, dynamic>) return body;
    return {};
  }
}
