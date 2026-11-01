import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedContent {
  final DateTime savedAt;
  final List<dynamic> records;
  const CachedContent(this.savedAt, this.records);
}

/// Public information only: never store phone, bank or identity information.
class ContentCache {
  ContentCache({SharedPreferencesAsync? preferences})
    : _providedPreferences = preferences;
  final SharedPreferencesAsync? _providedPreferences;
  SharedPreferencesAsync get _preferences =>
      _providedPreferences ?? SharedPreferencesAsync();

  Future<void> clear() async {
    await _preferences.remove('public_cache_v1_market_cg');
    await _preferences.remove('public_cache_v1_farmer_news');
  }

  Future<CachedContent?> read(String key) async {
    try {
      final raw = await _preferences.getString('public_cache_v1_$key');
      if (raw == null || raw.length > 250000) return null;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.parse(data['savedAt'] as String).toLocal();
      if (savedAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
        return null;
      }
      return CachedContent(savedAt, data['records'] as List<dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> write(String key, List<Map<String, dynamic>> records) async {
    try {
      final encoded = jsonEncode({
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'records': records,
      });
      if (encoded.length > 250000) return false;
      await _preferences.setString('public_cache_v1_$key', encoded);
      return true;
    } catch (_) {
      // A browser with disabled storage can still show the current response.
      return false;
    }
  }
}
