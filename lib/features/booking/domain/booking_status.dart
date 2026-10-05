enum BookingStatus {
  confirmed,
  cancelled,
  completed,
}

extension BookingStatusLabel on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'BOOKING CONFIRMED';

      case BookingStatus.cancelled:
        return 'BOOKING CANCELLED';

      case BookingStatus.completed:
        return 'BOOKING COMPLETED';
    }
  }
}