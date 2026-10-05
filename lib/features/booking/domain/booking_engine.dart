import 'booking.dart';
import 'booking_status.dart';
import 'booking_status_event.dart';

class BookingEngine {
  static Booking cancel(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      throw StateError(
        'Only a confirmed booking can be cancelled.',
      );
    }

    final history = [
      ...booking.statusHistory,
      BookingStatusEvent(
        status: BookingStatus.cancelled,
        timestamp: DateTime.now(),
      ),
    ];

    return booking.copyWith(
      status: BookingStatus.cancelled,
      statusHistory: history,
    );
  }

  static Booking complete(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      throw StateError(
        'Only a confirmed booking can be completed.',
      );
    }

    final history = [
      ...booking.statusHistory,
      BookingStatusEvent(
        status: BookingStatus.completed,
        timestamp: DateTime.now(),
      ),
    ];

    return booking.copyWith(
      status: BookingStatus.completed,
      statusHistory: history,
    );
  }
}