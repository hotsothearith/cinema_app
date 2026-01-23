import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_paths.dart';
import '../../core/storage/token_storage.dart';
import '../../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final _tokenStorage = TokenStorage();

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  AppUser? _me;
  AppUser? get me => _me;

  bool get isLoggedIn => _me != null;

  Future<void> bootstrap() async {
    // If token exists, try /me
    _loading = true;
    notifyListeners();
    try {
      final token = await _tokenStorage.readToken();
      if (token != null && token.isNotEmpty) {
        await fetchMe();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMe() async {
    try {
      final res = await ApiClient.instance.dio.get(ApiPaths.me);
      final data = _unwrapData(res.data);
      _me = AppUser.fromJson(data as Map<String, dynamic>);
      _error = null;
      notifyListeners();
    } catch (e) {
      _me = null;
      _error = 'Session expired. Please login again.';
      await _tokenStorage.clear();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.post(
        ApiPaths.login,
        data: {'email': email, 'password': password},
      );

      final body = res.data as Map<String, dynamic>;
      final token = (body['token'] ?? '').toString();
      if (token.isEmpty) {
        _error = 'Login failed: token missing.';
        return false;
      }

      await _tokenStorage.saveToken(token);

      final userJson = body['user'];
      if (userJson is Map<String, dynamic>) {
        _me = AppUser.fromJson(userJson);
      } else {
        await fetchMe();
      }

      _error = null;
      return true;
    } catch (e) {
      _error = 'Login failed. Check your email/password.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final res = await ApiClient.instance.dio.post(
        ApiPaths.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      final body = res.data as Map<String, dynamic>;
      // some backends return token; if not, just login after
      final token = (body['token'] ?? '').toString();
      if (token.isNotEmpty) {
        await _tokenStorage.saveToken(token);
      }

      final userJson = body['user'];
      if (userJson is Map<String, dynamic>) {
        _me = AppUser.fromJson(userJson);
      } else {
        // fallback: try /me if token exists
        if (token.isNotEmpty) await fetchMe();
      }

      _error = null;
      return true;
    } catch (e) {
      _error = 'Register failed. Try another email.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await ApiClient.instance.dio.post(ApiPaths.logout);
    } catch (_) {
      // ignore
    }
    await _tokenStorage.clear();
    _me = null;
    _error = null;
    _setLoading(false);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  dynamic _unwrapData(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] != null) return body['data'];
    return body;
  }
}
