import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/visit_plan.dart';

/// Personal preparation notes only. This is never a booking outbox or evidence
/// of an official reservation. Do not store bank, Aadhaar or authentication data.
class VisitPlanStore {
  final SharedPreferencesAsync? _providedPreferences;
  late final SharedPreferencesAsync _preferences =
      _providedPreferences ?? SharedPreferencesAsync();
  final String _key;
  Future<void> _pending = Future.value();

  VisitPlanStore({String owner = 'guest', SharedPreferencesAsync? preferences})
    : _providedPreferences = preferences,
      _key = 'krishi.visitPlans.v1.${Uri.encodeComponent(owner)}';

  Future<List<VisitPlan>> load() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return [];
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      if (envelope['version'] != 1) throw const FormatException();
      return (envelope['plans'] as List)
          .map(
            (item) =>
                VisitPlan.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      // Preserve the original data so a parse error never silently overwrites it.
      throw const FormatException(
        'Saved plans could not be read. Clear them in Settings only if you no longer need them.',
      );
    }
  }

  Future<void> save(VisitPlan plan) {
    plan.validate();
    return _serialize(() async {
      final plans = await load();
      plans.removeWhere((item) => item.id == plan.id);
      if (plans.length >= 20) {
        throw StateError('Keep up to 20 plans. Delete an old plan first.');
      }
      plans.insert(0, plan);
      await _write(plans);
    });
  }

  Future<void> delete(String id) => _serialize(() async {
    final plans = await load();
    plans.removeWhere((item) => item.id == id);
    await _write(plans);
  });

  Future<void> clear() => _serialize(() => _preferences.remove(_key));

  Future<void> _write(List<VisitPlan> plans) => _preferences.setString(
    _key,
    jsonEncode({
      'version': 1,
      'plans': plans.map((item) => item.toJson()).toList(),
    }),
  );

  Future<void> _serialize(Future<void> Function() work) {
    final next = _pending.then((_) => work());
    _pending = next.catchError((Object _) {});
    return next;
  }
}
