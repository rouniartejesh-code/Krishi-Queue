import 'queue_status.dart';
import 'queue_engine.dart';

class QueueState {
  final String token;
  final String centre;
  final String crop;
  final int quantityQuintals;
  final String deliveryDate;
  final String slot;
  final int queuePosition;
  final int averageProcessingTimeMinutes;
  final int centreDelayBufferMinutes;
  final QueueStatus status;

  const QueueState({
    required this.token,
    required this.centre,
    required this.crop,
    required this.quantityQuintals,
    required this.deliveryDate,
    required this.slot,
    required this.queuePosition,
    required this.averageProcessingTimeMinutes,
    required this.centreDelayBufferMinutes,
    required this.status,
  });

  int get estimatedWaitMinutes {
    return QueueEngine.calculateEta(
      queuePosition: queuePosition,
      averageProcessingTimeMinutes: averageProcessingTimeMinutes,
      centreDelayBufferMinutes: centreDelayBufferMinutes,
    );
  }

  QueueState copyWith({
    String? token,
    String? centre,
    String? crop,
    int? quantityQuintals,
    String? deliveryDate,
    String? slot,
    int? queuePosition,
    int? averageProcessingTimeMinutes,
    int? centreDelayBufferMinutes,
    QueueStatus? status,
  }) {
    return QueueState(
      token: token ?? this.token,
      centre: centre ?? this.centre,
      crop: crop ?? this.crop,
      quantityQuintals: quantityQuintals ?? this.quantityQuintals,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      slot: slot ?? this.slot,
      queuePosition: queuePosition ?? this.queuePosition,
      averageProcessingTimeMinutes:
          averageProcessingTimeMinutes ?? this.averageProcessingTimeMinutes,
      centreDelayBufferMinutes:
          centreDelayBufferMinutes ?? this.centreDelayBufferMinutes,
      status: status ?? this.status,
    );
  }
}
