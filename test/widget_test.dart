import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/core/settings/app_preferences.dart';
import 'package:krishi_queue/features/auth/presentation/login_screen.dart';
import 'package:krishi_queue/main.dart';

void main() {
  testWidgets('Hindi sign-in keeps offline help available', (tester) async {
    await AppPreferences.instance.setHindi(true);
    await tester.pumpWidget(const KrishiQueueApp());
    await tester.pumpAndSettle();

    expect(find.text('Krishi Queue'), findsOneWidget);
    expect(find.text('बिना साइन इन किए आगे बढ़ें'), findsOneWidget);
    expect(find.text('OTP भेजें'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline entry needs no Firebase and fits large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var entered = false;
    await tester.pumpWidget(
      AppPreferencesScope(
        preferences: AppPreferences.instance,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: LoginScreen(onContinueOffline: () => entered = true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final offlineButton = find.text('बिना साइन इन किए आगे बढ़ें');
    await tester.ensureVisible(offlineButton);
    await tester.tap(offlineButton);
    expect(entered, isTrue);
    expect(tester.takeException(), isNull);
  });
}
