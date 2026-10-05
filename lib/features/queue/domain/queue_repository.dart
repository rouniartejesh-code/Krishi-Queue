import 'queue_state.dart';

abstract class QueueRepository {
  Future<QueueState> getQueueState();

  Future<QueueState> advanceQueue(QueueState current);
}