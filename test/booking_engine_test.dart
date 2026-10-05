import 'package:flutter_test/flutter_test.dart';

import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/booking/domain/booking_engine.dart';
import 'package:krishi_queue/features/booking/domain/booking_status.dart';

void main() {
  group('BookingEngine', () {
    test('cancels a confirmed booking and records history', () {
      final booking = BookingEngine.cancel(demoBooking);

      expect(
        booking.status,
        BookingStatus.cancelled,
      );

      expect(
        booking.statusHistory.length,
        demoBooking.statusHistory.length + 1,
      );

      expect(
        booking.statusHistory.last.status,
        BookingStatus.cancelled,
      );
    });

    test('completes a confirmed booking and records history', () {
      final booking = BookingEngine.complete(demoBooking);

      expect(
        booking.status,
        BookingStatus.completed,
      );

      expect(
        booking.statusHistory.length,
        demoBooking.statusHistory.length + 1,
      );

      expect(
        booking.statusHistory.last.status,
        BookingStatus.completed,
      );
    });

    test('preserves the original confirmation history', () {
      final booking = BookingEngine.cancel(demoBooking);

      expect(
        booking.statusHistory.first.status,
        BookingStatus.confirmed,
      );
    });

    test('cannot cancel an already cancelled booking', () {
      final cancelled = BookingEngine.cancel(demoBooking);

      expect(
        () => BookingEngine.cancel(cancelled),
        throwsStateError,
      );
    });

    test('cannot complete an already completed booking', () {
      final completed = BookingEngine.complete(demoBooking);

      expect(
        () => BookingEngine.complete(completed),
        throwsStateError,
      );
    });
  });
}