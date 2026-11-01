enum QueueStatus { bookingConfirmed, yourTurnNext }

extension QueueStatusLabel on QueueStatus {
  String get label {
    switch (this) {
      case QueueStatus.bookingConfirmed:
        return 'BOOKING CONFIRMED';

      case QueueStatus.yourTurnNext:
        return 'YOUR TURN NEXT';
    }
  }
}
