import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/features/booking/data/demo_booking.dart';
import 'package:krishi_queue/features/queue/domain/queue_engine.dart';

void main() {
  test('wait estimate counts people ahead, not the farmer being served', () {
    expect(
      QueueEngine.calculateEta(
        queuePosition: 1,
        averageProcessingTimeMinutes: 6,
        centreDelayBufferMinutes: 0,
      ),
      0,
    );
    expect(
      QueueEngine.calculateEta(
        queuePosition: 6,
        averageProcessingTimeMinutes: 6,
        centreDelayBufferMinutes: 6,
      ),
      36,
    );
    expect(demoBooking.estimatedWaitMinutes, 36);
  });
  test('repeated advancement cannot move a token below first place', () {
    var queue = demoBooking.queueState;
    for (var i = 0; i < 20; i++) {
      queue = QueueEngine.advanceQueue(queue);
    }
    expect(queue.queuePosition, 1);
    expect(queue.estimatedWaitMinutes, 0);
  });
  test('negative timing is rejected', () {
    expect(
      () => QueueEngine.calculateEta(
        queuePosition: 1,
        averageProcessingTimeMinutes: -1,
        centreDelayBufferMinutes: 0,
      ),
      throwsArgumentError,
    );
  });
}
