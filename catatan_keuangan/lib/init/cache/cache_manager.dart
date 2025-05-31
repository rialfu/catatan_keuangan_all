// import 'package:flutter/foundation.dart' show immutable;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheManager {
  const CacheManager._();

  static const _androidOptions =
      AndroidOptions(encryptedSharedPreferences: true);
  static const _iosOptions =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(iOptions: _iosOptions, aOptions: _androidOptions);

  static Future<void> setString(String key, String value) async =>
      await _secureStorage.write(key: key, value: value);

  static Future<void> setBool(String key, bool value) async =>
      await _secureStorage.write(key: key, value: value.toString());

  static Future<String?> getString(String key) async =>
      await _secureStorage.read(key: key);

  static Future<bool?> getBool(String key) async {
    String? string = await _secureStorage.read(key: key);
    if (string == null) return null;
    if (string == 'true') {
      return true;
    } else if (string == 'false') {
      return false;
    } else {
      return null;
    }
  }

  static Future<void> setMap(String key, Map<String, dynamic> data) async {
    String value = jsonEncode(data);
    await _secureStorage.write(key: key, value: value);
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    String? data = await _secureStorage.read(key: key);
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (err) {
      await remove(key);
      return null;
    }
  }

  static Future<void> remove(String key) async =>
      await _secureStorage.delete(key: key);

  static Future<bool> containsKey(String key) async =>
      await _secureStorage.containsKey(key: key);

  static Future<void> clearAll() async => await _secureStorage.deleteAll();
}
