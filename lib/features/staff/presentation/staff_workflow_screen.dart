import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_engine.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_status.dart';
import '../../procurement/domain/procurement_engine.dart';
import '../../procurement/domain/procurement_status.dart';

class StaffWorkflowScreen extends StatefulWidget {
  final BookingRepository repository;

  const StaffWorkflowScreen({
    super.key,
    required this.repository,
  });

  @override
  State<StaffWorkflowScreen> createState() => _StaffWorkflowScreenState();
}

class _StaffWorkflowScreenState extends State<StaffWorkflowScreen> {
  Booking? _booking;
  bool _loading = true;
  bool _advancing = false;
  bool _driverAssigned = false;
  bool _driverArrived = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      final booking = await widget.repository.getBooking();

      if (!mounted) return;

      setState(() {
        _booking = booking;
        _driverAssigned = booking.driverAssigned;
        _driverArrived = booking.driverArrived;
        _loading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _assignDriver() async {
    final booking = _booking;
    if (booking == null || _driverAssigned) return;

    try {
      final updated = booking.copyWith(
        driverId: 'DRV-DEMO-01',
        driverAssigned: true,
        driverArrived: false,
      );
      final saved = await widget.repository.updateBooking(updated);

      if (!mounted) return;
      setState(() {
        _booking = saved;
        _driverAssigned = true;
        _driverArrived = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyError(error));
    }
  }

  Future<void> _markDriverArrived() async {
    final booking = _booking;
    if (booking == null || !_driverAssigned || _driverArrived) return;

    try {
      final updated = booking.copyWith(driverArrived: true);
      final saved = await widget.repository.updateBooking(updated);

      if (!mounted) return;
      setState(() {
        _booking = saved;
        _driverArrived = true;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyError(error));
    }
  }

  Future<void> _advanceWorkflow() async {
    final booking = _booking;

    if (booking == null || _advancing) return;

    final status = booking.procurement.status;

    if (!ProcurementEngine.canAdvance(status)) return;

    if (!_driverAssigned) {
      setState(() {
        _errorMessage = 'Assign a driver before processing this booking.';
      });
      return;
    }

    if (!_driverArrived) {
      setState(() {
        _errorMessage = 'Mark the assigned driver as arrived before gate processing.';
      });
      return;
    }

    if (status == ProcurementStatus.awaitingGate &&
        booking.queueState.queuePosition > 1) {
      setState(() {
        _errorMessage =
            'Gate verification is locked. Token ${booking.token} is queue #${booking.queueState.queuePosition}. Reach #1 to continue.';
      });
      return;
    }

    setState(() {
      _advancing = true;
      _errorMessage = null;
    });

    try {
      var updatedBooking = ProcurementEngine.advance(booking);

      if (updatedBooking.procurement.status == ProcurementStatus.paymentPaid &&
          updatedBooking.status != BookingStatus.completed) {
        updatedBooking = BookingEngine.complete(updatedBooking);
      }

      final saved = await widget.repository.updateBooking(updatedBooking);

      if (!mounted) return;

      setState(() {
        _booking = saved;
        _advancing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _advancing = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString().replaceFirst('Bad state: ', '');

    if (message.contains('queue position is #1')) {
      final booking = _booking;
      if (booking != null && booking.queueState.queuePosition > 1) {
        return 'Gate verification is locked. Token ${booking.token} is queue #${booking.queueState.queuePosition}. Reach #1 to continue.';
      }
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final booking = _booking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Staff Workflow',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: const Center(child: Text('No active booking found.')),
      );
    }

    final status = booking.procurement.status;
    final complete = status == ProcurementStatus.paymentPaid;
    final gateLocked = status == ProcurementStatus.awaitingGate &&
        booking.queueState.queuePosition > 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Workflow',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 12),
            ],
            _buildBookingHeader(booking),
            const SizedBox(height: 16),
            _buildDriverSection(),
            const SizedBox(height: 20),
            const Text(
              'Operational Workflow',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeline(status),
            const SizedBox(height: 18),
            _buildRecords(booking),
            const SizedBox(height: 18),
            if (!complete)
              FilledButton.icon(
                onPressed: _advancing || gateLocked
                    ? null
                    : _advanceWorkflow,
                icon: _advancing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        gateLocked
                            ? Icons.lock_outline_rounded
                            : Icons.fast_forward_rounded,
                      ),
                label: Text(
                  _advancing
                      ? 'Updating...'
                      : gateLocked
                          ? 'Waiting for Queue #1'
                          : _nextAction(status),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryGreen,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Booking completed. Procurement and payment are complete in the demo.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentOrange.withValues(alpha: .35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.accentOrange,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action unavailable',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.close_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(Booking booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.bookingNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightOrange,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    booking.procurement.status.label,
                    style: const TextStyle(
                      color: AppTheme.accentOrange,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _InfoRow('Token', booking.token),
            _InfoRow('Queue', '#${booking.queuePosition}'),
            _InfoRow('Centre', booking.queueState.centre),
            _InfoRow('Crop', booking.queueState.crop),
            _InfoRow('Quantity', '${booking.quantityQtl} QTL', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver & Arrival',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Demo assignment is persisted on the shared booking record.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _DriverStep(
                  icon: Icons.local_shipping_outlined,
                  title: 'Driver assigned',
                  done: _driverAssigned,
                ),
                const SizedBox(width: 10),
                _DriverStep(
                  icon: Icons.location_on_outlined,
                  title: 'Driver arrived',
                  done: _driverArrived,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _driverAssigned ? null : _assignDriver,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(
                      _driverAssigned ? 'Driver Assigned' : 'Assign Driver',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: !_driverAssigned || _driverArrived
                        ? null
                        : _markDriverArrived,
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      _driverArrived ? 'Arrived' : 'Mark Arrived',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ProcurementStatus current) {
    const stages = [
      _Stage('Gate Verification', ProcurementStatus.gateVerified),
      _Stage('Weighing', ProcurementStatus.weighingCompleted),
      _Stage('Quality Check', ProcurementStatus.qualityPassed),
      _Stage('Bill Generated', ProcurementStatus.billGenerated),
      _Stage('Bank Transfer', ProcurementStatus.bankTransferTriggered),
      _Stage('PAID', ProcurementStatus.paymentPaid),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
        child: Column(
          children: [
            _TimelineRow(
              title: 'Booking Confirmed',
              done: true,
              active: current == ProcurementStatus.awaitingGate,
              isLast: false,
            ),
            for (var index = 0; index < stages.length; index++)
              _TimelineRow(
                title: stages[index].title,
                done: current.index >= stages[index].status.index,
                active: current == stages[index].status,
                isLast: index == stages.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecords(Booking booking) {
    final p = booking.procurement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operational Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 13),
            _InfoRow(
              'Market reference',
              p.marketReferenceModalPricePerQtl == null
                  ? 'Not available'
                  : '₹${p.marketReferenceModalPricePerQtl!.toStringAsFixed(0)} / QTL',
            ),
            _InfoRow(
              'Procurement rate',
              p.procurementRatePerQtl == null
                  ? 'Not set'
                  : '₹${p.procurementRatePerQtl!.toStringAsFixed(0)} / QTL',
            ),
            _InfoRow(
              'Gross weight',
              p.grossWeightKg == null
                  ? 'Pending'
                  : '${p.grossWeightKg!.toStringAsFixed(0)} kg',
            ),
            _InfoRow(
              'Tare weight',
              p.tareWeightKg == null
                  ? 'Pending'
                  : '${p.tareWeightKg!.toStringAsFixed(0)} kg',
            ),
            _InfoRow(
              'Net weight',
              p.netWeightKg == null
                  ? 'Pending'
                  : '${p.netWeightKg!.toStringAsFixed(0)} kg',
            ),
            _InfoRow('Quality grade', p.qualityGrade ?? 'Pending'),
            _InfoRow(
              'Bill amount',
              p.billAmount == null
                  ? 'Pending'
                  : '₹${p.billAmount!.toStringAsFixed(0)}',
            ),
            _InfoRow(
              'Payment reference',
              p.paymentReference ?? 'Pending',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  String _nextAction(ProcurementStatus status) {
    switch (status) {
      case ProcurementStatus.awaitingGate:
        return 'Verify Gate';
      case ProcurementStatus.gateVerified:
        return 'Complete Weighing';
      case ProcurementStatus.weighingCompleted:
        return 'Complete Quality Check';
      case ProcurementStatus.qualityPassed:
        return 'Generate Bill';
      case ProcurementStatus.billGenerated:
        return 'Trigger Demo Transfer';
      case ProcurementStatus.bankTransferTriggered:
        return 'Mark Payment Paid';
      case ProcurementStatus.paymentPaid:
        return 'Completed';
    }
  }
}

class _Stage {
  final String title;
  final ProcurementStatus status;

  const _Stage(this.title, this.status);
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final bool done;
  final bool active;
  final bool isLast;

  const _TimelineRow({
    required this.title,
    required this.done,
    required this.active,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: done ? Colors.white : AppTheme.textSecondary,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  color: done
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: done || active
                    ? FontWeight.w800
                    : FontWeight.w600,
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

class _DriverStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool done;

  const _DriverStep({
    required this.icon,
    required this.title,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: done
              ? const Color(0xFFE8F5E9)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done
                ? AppTheme.primaryGreen.withValues(alpha: .25)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : icon,
              size: 20,
              color: done
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow(
    this.label,
    this.value, {
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 11),
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
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
