import 'procurement_status.dart';
import 'procurement_status_event.dart';

class ProcurementState {
  final ProcurementStatus status;
  final List<ProcurementStatusEvent> history;

  // Market price is reference information only. It must not be treated
  // as the procurement settlement rate.
  final double? marketReferenceModalPricePerQtl;

  // Demo procurement rate used only until an authoritative procurement
  // rate/backend billing rule is connected.
  final double? procurementRatePerQtl;

  final double? grossWeightKg;
  final double? tareWeightKg;
  final double? netWeightKg;
  final String? qualityGrade;
  final double? billAmount;
  final String? paymentReference;

  const ProcurementState({
    this.status = ProcurementStatus.awaitingGate,
    this.history = const [],
    this.marketReferenceModalPricePerQtl,
    this.procurementRatePerQtl,
    this.grossWeightKg,
    this.tareWeightKg,
    this.netWeightKg,
    this.qualityGrade,
    this.billAmount,
    this.paymentReference,
  });

  ProcurementState copyWith({
    ProcurementStatus? status,
    List<ProcurementStatusEvent>? history,
    double? marketReferenceModalPricePerQtl,
    double? procurementRatePerQtl,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    String? qualityGrade,
    double? billAmount,
    String? paymentReference,
  }) {
    return ProcurementState(
      status: status ?? this.status,
      history: history ?? this.history,
      marketReferenceModalPricePerQtl:
          marketReferenceModalPricePerQtl ??
          this.marketReferenceModalPricePerQtl,
      procurementRatePerQtl:
          procurementRatePerQtl ?? this.procurementRatePerQtl,
      grossWeightKg: grossWeightKg ?? this.grossWeightKg,
      tareWeightKg: tareWeightKg ?? this.tareWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      billAmount: billAmount ?? this.billAmount,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }
}
