import 'booking.dart';

class BookingValidator {
  static void validate(Booking booking) {
    if (booking.bookingNumber.trim().isEmpty) {
      throw ArgumentError('Booking number is required.');
    }

    if (booking.farmerId.trim().isEmpty) {
      throw ArgumentError('Farmer ID is required.');
    }

    if (booking.centreId.trim().isEmpty) {
      throw ArgumentError('Centre ID is required.');
    }

    if (booking.cropId.trim().isEmpty) {
      throw ArgumentError('Crop ID is required.');
    }

    if (booking.slotId.trim().isEmpty) {
      throw ArgumentError('Slot ID is required.');
    }

    if (booking.quantityQtl <= 0) {
      throw ArgumentError(
        'Quantity must be greater than zero.',
      );
    }

    if (booking.deliveryDate.trim().isEmpty) {
      throw ArgumentError('Delivery date is required.');
    }

    if (booking.queueState.token.trim().isEmpty) {
      throw ArgumentError('Queue token is required.');
    }

    if (booking.queueState.queuePosition < 1) {
      throw ArgumentError(
        'Queue position must be at least 1.',
      );
    }
  }
}