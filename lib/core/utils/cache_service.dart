import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const Duration defaultCacheDuration = Duration(hours: 4);

  static const String _keyPrefix = 'movie_app_cache_';
  static const String _timestampPrefix = 'movie_app_timestamp_';

  late final Box _cacheBox;
  late final SharedPreferences _prefs;

  static CacheService? _instance;

  static Future<CacheService> getInstance() async {
    if (_instance == null) {
      final instance = CacheService._();
      await instance._init();
      _instance = instance;
    }
    return _instance!;
  }

  CacheService._();

  Future<void> _init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('movie_app_cache');
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveData<T>({
    required String key,
    required T data,
    Duration cacheDuration = defaultCacheDuration,
  }) async {
    final cacheKey = '$_keyPrefix$key';
    final timestampKey = '$_timestampPrefix$key';
    final expiryTime = DateTime.now().add(cacheDuration).millisecondsSinceEpoch;

    try {
      if (data is Map || data is List) {
        await _cacheBox.put(cacheKey, json.encode(data));
      } else {
        await _cacheBox.put(cacheKey, data);
      }
      await _prefs.setInt(timestampKey, expiryTime);
    } catch (e) {
      debugPrint('Error saving data to cache: $e');
    }
  }

  Future<T?> getData<T>(String key) async {
    final cacheKey = '$_keyPrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    try {
      if (!_cacheBox.containsKey(cacheKey)) {
        return null;
      }

      final expiryTimestamp = _prefs.getInt(timestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiryTimestamp) {
        await _cacheBox.delete(cacheKey);
        await _prefs.remove(timestampKey);
        return null;
      }

      final data = _cacheBox.get(cacheKey);

      if (data is String) {
        try {
          final decoded = json.decode(data);
          return decoded as T;
        } catch (_) {
          return data as T;
        }
      }

      return data as T;
    } catch (e) {
      debugPrint('Error retrieving data from cache: $e');
      return null;
    }
  }

  Future<bool> hasValidCache(String key) async {
    final timestampKey = '$_timestampPrefix$key';
    final cacheKey = '$_keyPrefix$key';

    if (!_cacheBox.containsKey(cacheKey)) {
      return false;
    }

    final expiryTimestamp = _prefs.getInt(timestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    return now <= expiryTimestamp;
  }

  Future<void> invalidateCache(String key) async {
    final cacheKey = '$_keyPrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    await _cacheBox.delete(cacheKey);
    await _prefs.remove(timestampKey);
  }

  Future<void> clearAllCache() async {
    await _cacheBox.clear();

    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_timestampPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  Future<void> purgeExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_timestampPrefix)) {
        final expiryTimestamp = _prefs.getInt(key) ?? 0;

        if (now > expiryTimestamp) {
          final originalKey = key.substring(_timestampPrefix.length);
          final cacheKey = '$_keyPrefix$originalKey';

          await _cacheBox.delete(cacheKey);
          await _prefs.remove(key);
        }
      }
    }
  }
}
