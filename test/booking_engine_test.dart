import 'package:flutter_test/flutter_test.dart';

import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/booking/domain/booking_engine.dart';
import 'package:krishi_queue/features/booking/domain/booking_status.dart';
import 'package:krishi_queue/features/procurement/domain/procurement_status.dart';

void main() {
  final paidBooking = demoBooking.copyWith(
    procurement: demoBooking.procurement.copyWith(
      status: ProcurementStatus.paymentPaid,
      paymentReference: 'DEMO-PAID',
    ),
  );
  group('BookingEngine', () {
    test('cancels a confirmed booking and records history', () {
      final booking = BookingEngine.cancel(demoBooking);

      expect(booking.status, BookingStatus.cancelled);

      expect(
        booking.statusHistory.length,
        demoBooking.statusHistory.length + 1,
      );

      expect(booking.statusHistory.last.status, BookingStatus.cancelled);
    });

    test('completes a confirmed booking and records history', () {
      final booking = BookingEngine.complete(paidBooking);

      expect(booking.status, BookingStatus.completed);

      expect(
        booking.statusHistory.length,
        demoBooking.statusHistory.length + 1,
      );

      expect(booking.statusHistory.last.status, BookingStatus.completed);
    });

    test('preserves the original confirmation history', () {
      final booking = BookingEngine.cancel(demoBooking);

      expect(booking.statusHistory.first.status, BookingStatus.confirmed);
    });

    test('cannot cancel an already cancelled booking', () {
      final cancelled = BookingEngine.cancel(demoBooking);

      expect(() => BookingEngine.cancel(cancelled), throwsStateError);
    });

    test('cannot complete an already completed booking', () {
      final completed = BookingEngine.complete(paidBooking);

      expect(() => BookingEngine.complete(completed), throwsStateError);
    });
    test('does not mark unpaid produce complete', () {
      expect(() => BookingEngine.complete(demoBooking), throwsStateError);
    });
    test('does not discard an arrival by cancelling', () {
      final arrived = demoBooking.copyWith(
        procurement: demoBooking.procurement.copyWith(
          status: ProcurementStatus.gateVerified,
        ),
      );
      expect(() => BookingEngine.cancel(arrived), throwsStateError);
    });
  });
}
