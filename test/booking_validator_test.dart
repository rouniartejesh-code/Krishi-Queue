import 'package:flutter_test/flutter_test.dart';

import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/booking/domain/booking_validator.dart';

void main() {
  group('BookingValidator', () {
    test('accepts a valid booking', () {
      expect(
        () => BookingValidator.validate(demoBooking),
        returnsNormally,
      );
    });

    test('rejects empty booking number', () {
      final booking = demoBooking.copyWith(
        bookingNumber: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty farmer ID', () {
      final booking = demoBooking.copyWith(
        farmerId: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty centre ID', () {
      final booking = demoBooking.copyWith(
        centreId: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty crop ID', () {
      final booking = demoBooking.copyWith(
        cropId: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty slot ID', () {
      final booking = demoBooking.copyWith(
        slotId: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects zero quantity', () {
      final booking = demoBooking.copyWith(
        quantityQtl: 0,
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects negative quantity', () {
      final booking = demoBooking.copyWith(
        quantityQtl: -10,
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty delivery date', () {
      final booking = demoBooking.copyWith(
        deliveryDate: '',
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects empty token', () {
      final booking = demoBooking.copyWith(
        queueState: demoBooking.queueState.copyWith(
          token: '',
        ),
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });

    test('rejects invalid queue position', () {
      final booking = demoBooking.copyWith(
        queueState: demoBooking.queueState.copyWith(
          queuePosition: 0,
        ),
      );

      expect(
        () => BookingValidator.validate(booking),
        throwsArgumentError,
      );
    });
  });
}