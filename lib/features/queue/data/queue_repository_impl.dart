import '../domain/queue_engine.dart';
import '../domain/queue_repository.dart';
import '../domain/queue_state.dart';

class QueueRepositoryImpl implements QueueRepository {
  QueueState _state;

  QueueRepositoryImpl(QueueState initialState)
      : _state = initialState;

  @override
  Future<QueueState> getQueueState() async {
    return _state;
  }

  @override
  Future<QueueState> advanceQueue(QueueState current) async {
    _state = QueueEngine.advanceQueue(current);
    return _state;
  }
}