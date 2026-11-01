import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_status.dart';
import 'procurement_status.dart';
import 'procurement_status_event.dart';

class ProcurementEngine {
  static Booking advance(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      throw StateError('Only a confirmed booking can enter procurement.');
    }

    final current = booking.procurement.status;

    if (current == ProcurementStatus.awaitingGate &&
        booking.queueState.queuePosition > 1) {
      throw StateError(
        'Gate verification is available when your queue position is #1.',
      );
    }

    final next = _nextStatus(current);

    if (next == null) {
      throw StateError('Procurement lifecycle is already complete.');
    }

    var procurement = booking.procurement;

    if (next == ProcurementStatus.weighingCompleted) {
      final grossWeight = booking.quantityQtl.toDouble() * 100.0 + 200.0;
      const tareWeight = 200.0;
      final netWeight = grossWeight - tareWeight;

      procurement = procurement.copyWith(
        grossWeightKg: grossWeight,
        tareWeightKg: tareWeight,
        netWeightKg: netWeight,
      );
    }

    if (next == ProcurementStatus.qualityPassed) {
      procurement = procurement.copyWith(qualityGrade: 'A');
    }

    if (next == ProcurementStatus.billGenerated) {
      final rate = procurement.procurementRatePerQtl;

      if (rate == null || !rate.isFinite || rate <= 0) {
        throw StateError(
          'A valid demo procurement rate is required before billing.',
        );
      }

      final netWeightKg =
          procurement.netWeightKg ?? booking.quantityQtl.toDouble() * 100.0;
      final approvedQuantityQtl = netWeightKg / 100.0;
      if (!netWeightKg.isFinite || netWeightKg <= 0) {
        throw StateError('A valid measured weight is required before billing.');
      }
      final billAmount = approvedQuantityQtl * rate;

      procurement = procurement.copyWith(billAmount: billAmount);
    }

    if (next == ProcurementStatus.paymentPaid) {
      procurement = procurement.copyWith(
        paymentReference: 'DEMO-DBT-${booking.bookingNumber}',
      );
    }

    final updatedHistory = [
      ...procurement.history,
      ProcurementStatusEvent(status: next, timestamp: DateTime.now()),
    ];

    procurement = procurement.copyWith(status: next, history: updatedHistory);

    return booking.copyWith(procurement: procurement);
  }

  static ProcurementStatus? _nextStatus(ProcurementStatus current) {
    switch (current) {
      case ProcurementStatus.awaitingGate:
        return ProcurementStatus.gateVerified;
      case ProcurementStatus.gateVerified:
        return ProcurementStatus.weighingCompleted;
      case ProcurementStatus.weighingCompleted:
        return ProcurementStatus.qualityPassed;
      case ProcurementStatus.qualityPassed:
        return ProcurementStatus.billGenerated;
      case ProcurementStatus.billGenerated:
        return ProcurementStatus.bankTransferTriggered;
      case ProcurementStatus.bankTransferTriggered:
        return ProcurementStatus.paymentPaid;
      case ProcurementStatus.paymentPaid:
        return null;
    }
  }

  static bool isComplete(ProcurementStatus status) {
    return status == ProcurementStatus.paymentPaid;
  }

  static bool canAdvance(ProcurementStatus status) {
    return !isComplete(status);
  }
}
