import 'booking_status.dart';

class BookingStatusEvent {
  final BookingStatus status;
  final DateTime timestamp;

  const BookingStatusEvent({
    required this.status,
    required this.timestamp,
  });
}