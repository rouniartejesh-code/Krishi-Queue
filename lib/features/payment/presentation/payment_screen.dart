import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../procurement/domain/procurement_status.dart';

class PaymentScreen extends StatefulWidget {
  final BookingRepository repository;

  const PaymentScreen({
    super.key,
    required this.repository,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Booking? _booking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final booking = await widget.repository.getBooking();

    if (!mounted) return;

    setState(() {
      _booking = booking;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final booking = _booking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment Status'),
        ),
        body: const Center(
          child: Text('No booking found.'),
        ),
      );
    }

    final procurement = booking.procurement;
    final status = procurement.status;
    final isPaid = status == ProcurementStatus.paymentPaid;
    final billGenerated = status.index >=
        ProcurementStatus.billGenerated.index;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Status',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildSimulationBanner(),
            const SizedBox(height: 14),
            _buildPaymentSummary(booking),
            const SizedBox(height: 20),
            const Text(
              'Payment Timeline',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
                child: Column(
                  children: [
                    _TimelineItem(
                      title: 'Booking Confirmed',
                      completed: true,
                      active: status == ProcurementStatus.awaitingGate,
                      isLast: false,
                    ),
                    _TimelineItem(
                      title: 'Gate Verified',
                      completed: status.index >=
                          ProcurementStatus.gateVerified.index,
                      active: status == ProcurementStatus.gateVerified,
                      isLast: false,
                    ),
                    _TimelineItem(
                      title: 'Weighed & Graded',
                      completed: status.index >=
                          ProcurementStatus.qualityPassed.index,
                      active: status == ProcurementStatus.weighingCompleted ||
                          status == ProcurementStatus.qualityPassed,
                      isLast: false,
                    ),
                    _TimelineItem(
                      title: 'Bill Generated',
                      completed: billGenerated,
                      active: status == ProcurementStatus.billGenerated,
                      isLast: false,
                    ),
                    _TimelineItem(
                      title: 'Bank Transfer Triggered',
                      completed: status.index >=
                          ProcurementStatus.bankTransferTriggered.index,
                      active: status == ProcurementStatus.bankTransferTriggered,
                      isLast: false,
                    ),
                    _TimelineItem(
                      title: 'PAID',
                      completed: isPaid,
                      active: isPaid,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildBillDetails(booking),
            const SizedBox(height: 18),
            _buildCurrentStatus(status),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.science_outlined,
            color: AppTheme.accentOrange,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYMENT SIMULATION',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No real bank transfer is performed. This demo shows the intended DBT payment workflow.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(Booking booking) {
    final procurement = booking.procurement;
    final amount = procurement.billAmount;
    final quantity = procurement.netWeightKg == null
        ? booking.quantityQtl.toDouble()
        : procurement.netWeightKg! / 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'PROCUREMENT PAYMENT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              if (booking.procurement.status ==
                  ProcurementStatus.paymentPaid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PAID',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount == null
                ? 'Bill pending'
                : '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _WhiteInfoRow(
            label: 'Crop',
            value: booking.queueState.crop,
          ),
          _WhiteInfoRow(
            label: 'Quantity',
            value: '${quantity.toStringAsFixed(2)} QTL',
          ),
          _WhiteInfoRow(
            label: 'Centre',
            value: booking.queueState.centre,
          ),
          _WhiteInfoRow(
            label: 'Token',
            value: booking.token,
          ),
          _WhiteInfoRow(
            label: 'Booking',
            value: booking.bookingNumber,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(Booking booking) {
    final procurement = booking.procurement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bill & Price Reference',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              label: 'Market modal',
              value: procurement.marketReferenceModalPricePerQtl == null
                  ? 'Not available'
                  : '₹${procurement.marketReferenceModalPricePerQtl!.toStringAsFixed(0)} / QTL',
            ),
            _InfoRow(
              label: 'Demo procurement rate',
              value: procurement.procurementRatePerQtl == null
                  ? 'Not set'
                  : '₹${procurement.procurementRatePerQtl!.toStringAsFixed(0)} / QTL',
            ),
            _InfoRow(
              label: 'Net weight',
              value: procurement.netWeightKg == null
                  ? 'Pending weighing'
                  : '${procurement.netWeightKg!.toStringAsFixed(0)} kg',
            ),
            _InfoRow(
              label: 'Quality grade',
              value: procurement.qualityGrade ?? 'Pending quality check',
            ),
            _InfoRow(
              label: 'Bill amount',
              value: procurement.billAmount == null
                  ? 'Pending bill'
                  : '₹${procurement.billAmount!.toStringAsFixed(0)}',
            ),
            if (procurement.paymentReference != null)
              _InfoRow(
                label: 'Payment reference',
                value: procurement.paymentReference!,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(ProcurementStatus status) {
    final paid = status == ProcurementStatus.paymentPaid;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFE8F5E9) : AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            paid ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: paid
                ? AppTheme.primaryGreen
                : AppTheme.accentOrange,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              status.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final bool completed;
  final bool active;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.completed,
    required this.active,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final done = completed || active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.circle_outlined,
                  size: 17,
                  color: done
                      ? Colors.white
                      : AppTheme.textSecondary,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 35,
                  color: completed
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 22),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: done ? FontWeight.w800 : FontWeight.w600,
                color: active
                    ? AppTheme.primaryGreen
                    : done
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _WhiteInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
