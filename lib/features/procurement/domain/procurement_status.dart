enum ProcurementStatus {
  awaitingGate,
  gateVerified,
  weighingCompleted,
  qualityPassed,
  billGenerated,
  bankTransferTriggered,
  paymentPaid,
}

extension ProcurementStatusLabel on ProcurementStatus {
  String get label {
    switch (this) {
      case ProcurementStatus.awaitingGate:
        return 'AWAITING GATE';
      case ProcurementStatus.gateVerified:
        return 'GATE VERIFIED';
      case ProcurementStatus.weighingCompleted:
        return 'WEIGHING COMPLETED';
      case ProcurementStatus.qualityPassed:
        return 'QUALITY PASSED';
      case ProcurementStatus.billGenerated:
        return 'BILL GENERATED';
      case ProcurementStatus.bankTransferTriggered:
        return 'BANK TRANSFER TRIGGERED';
      case ProcurementStatus.paymentPaid:
        return 'PAYMENT PAID';
    }
  }

  String get description {
    switch (this) {
      case ProcurementStatus.awaitingGate:
        return 'Present your QR token at the procurement centre.';
      case ProcurementStatus.gateVerified:
        return 'Your arrival has been verified at the gate.';
      case ProcurementStatus.weighingCompleted:
        return 'Your produce has been weighed.';
      case ProcurementStatus.qualityPassed:
        return 'Quality inspection has been completed.';
      case ProcurementStatus.billGenerated:
        return 'Your procurement bill has been generated.';
      case ProcurementStatus.bankTransferTriggered:
        return 'The demo bank transfer has been triggered.';
      case ProcurementStatus.paymentPaid:
        return 'Payment has been marked as completed in the demo.';
    }
  }
}
