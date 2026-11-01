import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/core/theme/app_theme.dart';
import 'package:krishi_queue/features/booking/data/booking_repository_impl.dart';
import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/procurement/domain/procurement_status.dart';
import 'package:krishi_queue/features/staff/presentation/staff_workflow_screen.dart';

void main() {
  testWidgets('own transport does not require assigning an app driver', (
    tester,
  ) async {
    final repository = BookingRepositoryImpl(
      demoBooking.copyWith(
        queueState: demoBooking.queueState.copyWith(queuePosition: 1),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: StaffWorkflowScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Verify Gate'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Verify Gate'));
    await tester.pumpAndSettle();
    expect(
      (await repository.getBooking()).procurement.status,
      ProcurementStatus.gateVerified,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('an assigned driver still needs recorded arrival', (
    tester,
  ) async {
    final repository = BookingRepositoryImpl(
      demoBooking.copyWith(
        queueState: demoBooking.queueState.copyWith(queuePosition: 1),
        driverAssigned: true,
        driverId: 'PRACTICE-DRIVER',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: StaffWorkflowScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Verify Gate'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Verify Gate'));
    await tester.pumpAndSettle();
    expect(
      (await repository.getBooking()).procurement.status,
      ProcurementStatus.awaitingGate,
    );
  });
}
