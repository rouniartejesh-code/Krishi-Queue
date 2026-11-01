import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krishi_queue/features/visit/data/visit_plan_store.dart';
import 'package:krishi_queue/features/visit/domain/visit_plan.dart';

// Mutable storage fake models disk errors without invoking a platform plugin.
// ignore: must_be_immutable
class MemoryPreferences extends Fake implements SharedPreferencesAsync {
  final Map<String, String> values = {};
  bool failWrites = false;
  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async {
    if (failWrites) throw StateError('Storage full');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

VisitPlan plan(String id) => VisitPlan(
  id: id,
  centre: 'My society',
  village: 'Raipur',
  crop: 'Paddy',
  quantity: 2.5,
  date: DateTime(2026, 11, 5),
  updatedAt: DateTime(2026, 10, 31),
  checklist: {'documents'},
);

void main() {
  test(
    'a saved visit survives a new store instance and preserves checklist',
    () async {
      final disk = MemoryPreferences();
      await VisitPlanStore(preferences: disk, owner: 'one').save(plan('a'));
      final loaded = await VisitPlanStore(
        preferences: disk,
        owner: 'one',
      ).load();
      expect(loaded.single.quantity, 2.5);
      expect(loaded.single.checklist, {'documents'});
      expect(
        await VisitPlanStore(preferences: disk, owner: 'two').load(),
        isEmpty,
      );
    },
  );
  test(
    'concurrent saves do not erase one another and retry is idempotent',
    () async {
      final store = VisitPlanStore(preferences: MemoryPreferences());
      await Future.wait([store.save(plan('a')), store.save(plan('b'))]);
      await store.save(plan('a'));
      expect((await store.load()).map((p) => p.id).toSet(), {'a', 'b'});
    },
  );
  test('storage failure is reported, next save can succeed', () async {
    final disk = MemoryPreferences()..failWrites = true;
    final store = VisitPlanStore(preferences: disk);
    await expectLater(store.save(plan('a')), throwsStateError);
    disk.failWrites = false;
    await store.save(plan('a'));
    expect(await store.load(), hasLength(1));
  });
  test('corrupt data is preserved rather than silently overwritten', () async {
    final disk = MemoryPreferences();
    disk.values['krishi.visitPlans.v1.guest'] = '{broken';
    final store = VisitPlanStore(preferences: disk);
    await expectLater(store.save(plan('a')), throwsFormatException);
    expect(disk.values.values.single, '{broken');
  });
  test('delete affects only the selected plan and owner', () async {
    final disk = MemoryPreferences();
    final a = VisitPlanStore(preferences: disk, owner: 'a');
    final b = VisitPlanStore(preferences: disk, owner: 'b');
    await a.save(plan('1'));
    await a.save(plan('2'));
    await b.save(plan('1'));
    await a.delete('1');
    expect((await a.load()).single.id, '2');
    await a.clear();
    expect(await a.load(), isEmpty);
    expect(await b.load(), hasLength(1));
  });
  test('non-finite quantity cannot be persisted', () {
    final json = plan('x').toJson()..['quantity'] = double.nan;
    expect(() => VisitPlan.fromJson(json), throwsFormatException);
  });
}
