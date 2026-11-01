import 'procurement_status.dart';

class ProcurementStatusEvent {
  final ProcurementStatus status;
  final DateTime timestamp;

  const ProcurementStatusEvent({required this.status, required this.timestamp});
}
