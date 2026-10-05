
import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/features/booking/data/booking_repository_impl.dart';
import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/booking/domain/booking_status.dart';

void main() {
  group('BookingRepositoryImpl', () {
    test('returns the initial booking', () async {
      final repository = BookingRepositoryImpl(demoBooking);

      final booking = await repository.getBooking();

      expect(booking.bookingNumber, 'BK-2026-000124');
      expect(booking.status, BookingStatus.confirmed);
    });

    test('cancels a confirmed booking and persists the change', () async {
      final repository = BookingRepositoryImpl(demoBooking);

      final booking = await repository.cancelBooking();
      final storedBooking = await repository.getBooking();

      expect(booking.status, BookingStatus.cancelled);
      expect(storedBooking.status, BookingStatus.cancelled);
      expect(storedBooking.statusHistory.last.status, BookingStatus.cancelled);
    });

    test('completes a confirmed booking and persists the change', () async {
      final repository = BookingRepositoryImpl(demoBooking);

      final booking = await repository.completeBooking();
      final storedBooking = await repository.getBooking();

      expect(booking.status, BookingStatus.completed);
      expect(storedBooking.status, BookingStatus.completed);
      expect(storedBooking.statusHistory.last.status, BookingStatus.completed);
    });

    test('rejects an invalid booking update', () async {
      final repository = BookingRepositoryImpl(demoBooking);

      final invalidBooking = demoBooking.copyWith(
        quantityQtl: 0,
      );

      expect(
        () => repository.updateBooking(invalidBooking),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}