import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Versioned key prefix — bump when the stored shape changes incompatibly.
const _prefix = 'cardvault.v1.';

Future<T?> load<T>(String key, T Function(dynamic) fromJson) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefix + key);
    if (raw == null) return null;
    return fromJson(jsonDecode(raw));
  } catch (_) {
    return null;
  }
}

Future<void> save(String key, dynamic value) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefix + key, jsonEncode(value));
    print('saved $key , $value');
  } catch (_) {
    // Storage is best-effort; the app keeps working from memory.
  }
}

Future<void> remove(String key) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefix + key);
  } catch (_) {}
}

Future<void> clearAll() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final k in keys) {
      await prefs.remove(k);
    }
  } catch (_) {}
}
