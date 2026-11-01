import '../../procurement/domain/procurement_state.dart';
import '../../queue/domain/queue_state.dart';
import 'booking_status.dart';
import 'booking_status_event.dart';

class Booking {
  final String bookingNumber;
  final String farmerId;
  final String centreId;
  final String cropId;
  final String slotId;
  final int quantityQtl;
  final String deliveryDate;
  final BookingStatus status;
  final QueueState queueState;
  final List<BookingStatusEvent> statusHistory;
  final ProcurementState procurement;
  final String? driverId;
  final bool driverAssigned;
  final bool driverArrived;

  Booking({
    required this.bookingNumber,
    required this.farmerId,
    required this.centreId,
    required this.cropId,
    required this.slotId,
    required this.quantityQtl,
    required this.deliveryDate,
    required this.status,
    required this.queueState,
    required this.statusHistory,
    this.procurement = const ProcurementState(),
    this.driverId,
    this.driverAssigned = false,
    this.driverArrived = false,
  });

  String get token => queueState.token;

  int get queuePosition => queueState.queuePosition;

  int get estimatedWaitMinutes => queueState.estimatedWaitMinutes;

  Booking copyWith({
    String? bookingNumber,
    String? farmerId,
    String? centreId,
    String? cropId,
    String? slotId,
    int? quantityQtl,
    String? deliveryDate,
    BookingStatus? status,
    QueueState? queueState,
    List<BookingStatusEvent>? statusHistory,
    ProcurementState? procurement,
    String? driverId,
    bool? driverAssigned,
    bool? driverArrived,
  }) {
    return Booking(
      bookingNumber: bookingNumber ?? this.bookingNumber,
      farmerId: farmerId ?? this.farmerId,
      centreId: centreId ?? this.centreId,
      cropId: cropId ?? this.cropId,
      slotId: slotId ?? this.slotId,
      quantityQtl: quantityQtl ?? this.quantityQtl,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      queueState: queueState ?? this.queueState,
      statusHistory: statusHistory ?? this.statusHistory,
      procurement: procurement ?? this.procurement,
      driverId: driverId ?? this.driverId,
      driverAssigned: driverAssigned ?? this.driverAssigned,
      driverArrived: driverArrived ?? this.driverArrived,
    );
  }
}
