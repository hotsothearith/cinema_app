import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kToken = 'auth_token';
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kToken, token);
      return;
    }
    await _secure.write(key: _kToken, value: token);
  }

  Future<String?> readToken() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_kToken);
    }
    return _secure.read(key: _kToken);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kToken);
      return;
    }
    await _secure.delete(key: _kToken);
  }
}
