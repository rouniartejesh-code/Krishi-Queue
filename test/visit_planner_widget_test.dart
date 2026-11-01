import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krishi_queue/core/settings/app_preferences.dart';
import 'package:krishi_queue/core/theme/app_theme.dart';
import 'package:krishi_queue/features/visit/data/visit_plan_store.dart';
import 'package:krishi_queue/features/visit/domain/visit_plan.dart';
import 'package:krishi_queue/features/visit/presentation/visit_planner_screen.dart';

// Mutable storage fake models disk failures and pending writes.
// ignore: must_be_immutable
class _MemoryPreferences extends Fake implements SharedPreferencesAsync {
  final values = <String, String>{};
  bool failWrites = false;
  Completer<void>? pendingWrite;

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    if (failWrites) throw StateError('Storage full');
    await pendingWrite?.future;
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

Future<void> _openApp(
  WidgetTester tester,
  _MemoryPreferences disk, {
  bool hindi = false,
  double width = 390,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  final preferences = AppPreferences();
  await preferences.setHindi(hindi);
  await tester.pumpWidget(
    AppPreferencesScope(
      preferences: preferences,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        locale: Locale(hindi ? 'hi' : 'en'),
        supportedLocales: const [Locale('hi'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: VisitPlannerScreen(store: VisitPlanStore(preferences: disk)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _reach(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 50,
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  final target = find.text(text);
  await _reach(tester, target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await _reach(tester, field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _fillRequired(WidgetTester tester) async {
  await _tap(tester, 'Prepare a visit');
  await _enter(tester, 'Your registered society / centre', 'Abhanpur society');
  await _enter(tester, 'Quantity in quintals', '१२.५');
}

void main() {
  testWidgets('saved visit and checklist survive reopening and editing', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final disk = _MemoryPreferences();
    await _openApp(tester, disk);
    await _fillRequired(tester);
    await _tap(tester, 'Documents required by my society are ready');
    await _enter(
      tester,
      'Notes (optional)',
      'Ask the society before arranging transport.',
    );
    await _tap(tester, 'Save on this device');

    final first = (await VisitPlanStore(preferences: disk).load()).single;
    expect(first.quantity, 12.5);
    expect(first.checklist, contains('documents'));
    expect(first.notes, 'Ask the society before arranging transport.');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await _openApp(tester, disk);
    await _tap(tester, 'Abhanpur society');
    await _enter(tester, 'Quantity in quintals', '14.25');
    await _tap(tester, 'Save on this device');
    final reopened = await VisitPlanStore(preferences: disk).load();
    expect(reopened, hasLength(1));
    expect(reopened.single.id, first.id);
    expect(reopened.single.quantity, 14.25);
    expect(reopened.single.checklist, first.checklist);
    expect(reopened.single.notes, first.notes);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save retains entries and can retry without duplication', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final disk = _MemoryPreferences()..failWrites = true;
    await _openApp(tester, disk);
    await _fillRequired(tester);
    await _tap(tester, 'Save on this device');
    expect(find.textContaining('Could not save.'), findsOneWidget);
    expect(disk.values, isEmpty);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Leave without saving?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    disk.failWrites = false;
    await _tap(tester, 'Save on this device');
    final saved = (await VisitPlanStore(preferences: disk).load()).single;
    expect(saved.centre, 'Abhanpur society');
    expect(saved.quantity, 12.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an in-flight save cannot silently discard a newer text edit', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final disk = _MemoryPreferences();
    await _openApp(tester, disk);
    await _fillRequired(tester);
    final save = find.text('Save on this device');
    await _reach(tester, save);
    disk.pendingWrite = Completer<void>();
    await tester.tap(save);
    await tester.pump();
    await tester.pump();
    final visibleFields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    );
    expect(visibleFields, isNotEmpty);
    expect(visibleFields.every((field) => field.enabled == false), isTrue);
    expect(find.text('Saving…'), findsOneWidget);
    disk.pendingWrite!.complete();
    await tester.pumpAndSettle();
    expect(
      (await VisitPlanStore(preferences: disk).load()).single.quantity,
      12.5,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('blocked clipboard reports a useful error without losing edits', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          throw PlatformException(code: 'clipboard-denied');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final disk = _MemoryPreferences();
    await _openApp(tester, disk);
    await _fillRequired(tester);
    await _tap(tester, 'Copy a checklist for sharing / paper');
    expect(find.textContaining('Copying is unavailable.'), findsOneWidget);
    expect(disk.values, isEmpty);
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Save on this device');
    expect(
      (await VisitPlanStore(preferences: disk).load()).single.centre,
      'Abhanpur society',
    );
  });

  testWidgets(
    'Hindi planner fits 320px at 2x text and handles older crop/date values',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final disk = _MemoryPreferences();
      await VisitPlanStore(preferences: disk).save(
        VisitPlan(
          id: 'existing',
          centre: 'अभनपुर सहकारी समिति',
          village: 'रायपुर',
          crop: 'Wheat',
          quantity: 12.5,
          date: DateTime.now().add(const Duration(days: 730)),
          updatedAt: DateTime.now(),
          checklist: {'documents'},
        ),
      );
      await _openApp(tester, disk, hindi: true, width: 320, textScale: 2);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'अभनपुर सहकारी समिति');
      expect(tester.takeException(), isNull);
      final date = find.textContaining('सोची गई तारीख:');
      await _reach(tester, date);
      expect(tester.takeException(), isNull);
      await tester.tap(date);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      final cancel = MaterialLocalizations.of(
        tester.element(find.byType(DatePickerDialog)),
      ).cancelButtonLabel;
      await tester.tap(find.text(cancel));
      await tester.pumpAndSettle();
      await _reach(tester, find.text('इस फ़ोन पर सहेजें'));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('इस फ़ोन पर सहेजें'));
      await tester.pumpAndSettle();
      expect(
        (await VisitPlanStore(preferences: disk).load()).single.crop,
        'Wheat',
      );
      expect(tester.takeException(), isNull);
      await _tap(tester, 'अभनपुर सहकारी समिति');
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('यह व्यक्तिगत तैयारी हटाएँ?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('रखें'));
      await tester.pumpAndSettle();
      expect((await VisitPlanStore(preferences: disk).load()), hasLength(1));
    },
  );
}
