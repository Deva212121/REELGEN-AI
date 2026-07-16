import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OfflineService {
  static const String _cachePrefix = 'cache_';

  // ---------- Cache Data ----------
  static Future<void> cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(data);
    await prefs.setString('$_cachePrefix$key', jsonData);
  }

  // ---------- Get Cached Data ----------
  static Future<dynamic> getCachedData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('$_cachePrefix$key');
    if (jsonData == null) return null;
    return jsonDecode(jsonData);
  }

  // ---------- Clear Cache ----------
  static Future<void> clearCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$key');
  }

  // ---------- Clear All Cache ----------
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}