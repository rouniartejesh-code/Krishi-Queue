import 'booking.dart';
import 'booking_status.dart';
import 'booking_status_event.dart';
import '../../procurement/domain/procurement_status.dart';

class BookingEngine {
  static Booking cancel(Booking booking) {
    if (booking.procurement.status != ProcurementStatus.awaitingGate) {
      throw StateError(
        'Arrival has already been recorded. Contact centre staff to resolve this booking.',
      );
    }
    if (booking.status != BookingStatus.confirmed) {
      throw StateError('Only a confirmed booking can be cancelled.');
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
    if (booking.procurement.status != ProcurementStatus.paymentPaid ||
        (booking.procurement.paymentReference?.trim().isEmpty ?? true)) {
      throw StateError(
        'A payment confirmation is required before completing a booking.',
      );
    }
    if (booking.status != BookingStatus.confirmed) {
      throw StateError('Only a confirmed booking can be completed.');
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
