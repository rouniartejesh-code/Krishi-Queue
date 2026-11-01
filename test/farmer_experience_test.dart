import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:krishi_queue/core/settings/app_preferences.dart';
import 'package:krishi_queue/core/theme/app_theme.dart';
import 'package:krishi_queue/features/booking/data/booking_repository_impl.dart';
import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/help/data/farmer_guides.dart';
import 'package:krishi_queue/features/help/presentation/help_screen.dart';
import 'package:krishi_queue/features/help/presentation/settings_screen.dart';
import 'package:krishi_queue/features/home/presentation/home_screen.dart';

class _MemoryPreferences implements SharedPreferencesAsync {
  _MemoryPreferences({this.fail = false});
  final values = <String, bool>{};
  final bool fail;

  @override
  Future<bool?> getBool(String key) async {
    if (fail) throw StateError('Storage unavailable');
    return values[key];
  }

  @override
  Future<void> setBool(String key, bool value) async {
    if (fail) throw StateError('Storage unavailable');
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MountProbe extends StatefulWidget {
  const _MountProbe({required this.onMount});
  final VoidCallback onMount;
  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('News content'));
}

Widget _app(AppPreferences preferences, Widget home, {double scale = 1}) =>
    AppPreferencesScope(
      preferences: preferences,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    );

void main() {
  test(
    'preferences survive a reload and rapid toggles keep the latest choice',
    () async {
      final storage = _MemoryPreferences();
      final preferences = AppPreferences(storage: storage);
      final first = preferences.setHindi(false);
      final second = preferences.setHindi(true);
      await Future.wait([
        first,
        second,
        preferences.setLowData(false),
        preferences.setLargeText(true),
      ]);
      final reloaded = AppPreferences(storage: storage);
      await reloaded.load();
      expect(reloaded.hindi, isTrue);
      expect(reloaded.lowData, isFalse);
      expect(reloaded.largeText, isTrue);
    },
  );

  test(
    'storage failures preserve useful settings and expose save failure',
    () async {
      final storage = _MemoryPreferences(fail: true);
      final preferences = AppPreferences(storage: storage);
      await preferences.load();
      expect(preferences.hindi, isTrue);
      expect(preferences.lowData, isTrue);
      await preferences.setHindi(false);
      expect(preferences.hindi, isFalse);
      expect(preferences.saveFailed, isTrue);
    },
  );

  test('offline guides search Hindi and English content without a service', () {
    expect(
      farmerGuides.where((guide) => guide.matches('bank statement')).single.id,
      'payment',
    );
    expect(
      farmerGuides.where((guide) => guide.matches('नमी')).single.id,
      'before-visit',
    );
    expect(
      farmerGuides.every(
        (guide) => guide.steps.length == guide.stepsHindi.length,
      ),
      isTrue,
    );
  });

  testWidgets('home leaves news unmounted until requested', (tester) async {
    final preferences = AppPreferences(storage: _MemoryPreferences());
    await preferences.setHindi(false);
    var mounts = 0;
    var plans = 0;
    await tester.pumpWidget(
      _app(
        preferences,
        HomeScreen(
          repository: BookingRepositoryImpl(demoBooking),
          newsScreen: _MountProbe(onMount: () => mounts++),
          onPlanVisit: () => plans++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(mounts, 0);
    await tester.tap(find.text('Plan my visit'));
    expect(plans, 1);
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(mounts, 1);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(mounts, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home and help fit a narrow phone with 2x text', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final preferences = AppPreferences(storage: _MemoryPreferences());
    await tester.pumpWidget(
      _app(
        preferences,
        HomeScreen(repository: BookingRepositoryImpl(demoBooking)),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(_app(preferences, const HelpScreen(), scale: 2));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField), 'नमी');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('केंद्र जाने से पहले'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('केंद्र जाने से पहले'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings switches language immediately and clearing needs confirmation',
    (tester) async {
      final preferences = AppPreferences(storage: _MemoryPreferences());
      var cleared = 0;
      await tester.pumpWidget(
        _app(
          preferences,
          SettingsScreen(
            onClearLocalData: () async {
              cleared++;
            },
          ),
        ),
      );
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Language & settings'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Clear my saved visit plans'),
        300,
      );
      await tester.tap(find.text('Clear my saved visit plans'));
      await tester.pumpAndSettle();
      expect(cleared, 0);
      await tester.tap(find.text('Keep data'));
      await tester.pumpAndSettle();
      expect(cleared, 0);
      await tester.tap(find.text('Clear my saved visit plans'));
      await tester.pumpAndSettle();
      expect(find.textContaining('current account or guest'), findsOneWidget);
      await tester.tap(find.text('Clear plans'));
      await tester.pumpAndSettle();
      expect(cleared, 1);
      expect(
        find.text('Your saved visit plans were cleared from this phone.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('settings and deletion dialog fit a small phone at 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final preferences = AppPreferences(storage: _MemoryPreferences());
    await tester.pumpWidget(
      _app(
        preferences,
        SettingsScreen(onClearLocalData: () async {}),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('अपनी सहेजी यात्रा योजनाएँ हटाएँ'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('अपनी सहेजी यात्रा योजनाएँ हटाएँ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
