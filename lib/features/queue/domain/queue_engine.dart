import 'queue_state.dart';
import 'queue_status.dart';

class QueueEngine {
  static int calculateEta({
    required int queuePosition,
    required int averageProcessingTimeMinutes,
    required int centreDelayBufferMinutes,
  }) {
    if (queuePosition < 0) {
      throw ArgumentError('Queue position cannot be negative.');
    }

    if (averageProcessingTimeMinutes < 0) {
      throw ArgumentError('Average processing time cannot be negative.');
    }

    if (centreDelayBufferMinutes < 0) {
      throw ArgumentError('Centre delay buffer cannot be negative.');
    }

    final farmersAhead = queuePosition > 0 ? queuePosition - 1 : 0;
    return (farmersAhead * averageProcessingTimeMinutes) +
        centreDelayBufferMinutes;
  }

  static QueueState advanceQueue(QueueState current) {
    final newPosition = current.queuePosition - 1;

    if (newPosition <= 1) {
      return current.copyWith(
        queuePosition: 1,
        centreDelayBufferMinutes: 0,
        status: QueueStatus.yourTurnNext,
      );
    }

    return current.copyWith(queuePosition: newPosition);
  }
}
