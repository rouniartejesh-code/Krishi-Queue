import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../procurement/domain/procurement_status.dart';
import '../../queue/domain/queue_engine.dart';
import 'staff_workflow_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  final BookingRepository repository;
  final VoidCallback? onLogout;

  const StaffDashboardScreen({
    super.key,
    required this.repository,
    this.onLogout,
  });

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  Booking? _booking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _loading = true;
    });

    try {
      final booking = await widget.repository.getBooking();

      if (!mounted) return;

      setState(() {
        _booking = booking;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load staff queue.'),
        ),
      );
    }
  }

  void _openWorkflow() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => StaffWorkflowScreen(
              repository: widget.repository,
            ),
          ),
        )
        .then((_) => _loadBooking());
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff Operations',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loadBooking,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh queue',
          ),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Switch role',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildDemoBanner(),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (booking == null)
              _buildEmptyState()
            else ...[
              _buildCentreHeader(booking),
              const SizedBox(height: 18),
              _buildMetrics(booking),
              const SizedBox(height: 22),
              const Text(
                "Today's Queue",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _buildBookingCard(booking),
              const SizedBox(height: 18),
              _buildQueueControl(booking),
              const SizedBox(height: 18),
              _buildWorkflowSummary(booking),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _openWorkflow,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: Text(
                  booking.procurement.status == ProcurementStatus.paymentPaid
                      ? 'View Completed Workflow'
                      : 'Open Procurement Workflow',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.badge_outlined, color: AppTheme.accentOrange),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STAFF DEMO MODE',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This screen operates on the same local demo booking used by the farmer flow.',
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

  Widget _buildCentreHeader(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROCUREMENT CENTRE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.queueState.centre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${booking.queueState.crop} • ${booking.quantityQtl} QTL',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(Booking booking) {
    final status = booking.procurement.status;
    final waiting = booking.queueState.queuePosition > 1
        ? booking.queueState.queuePosition - 1
        : 0;
    final pendingWeighing = status.index < ProcurementStatus.weighingCompleted.index;
    final pendingQuality = status.index < ProcurementStatus.qualityPassed.index;
    final pendingBilling = status.index < ProcurementStatus.billGenerated.index;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.confirmation_number_outlined,
                label: 'Current token',
                value: booking.token,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.people_outline_rounded,
                label: 'Waiting farmers',
                value: '$waiting',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.stacked_bar_chart_rounded,
                label: 'Centre load',
                value: '${booking.queueState.queuePosition} in queue',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.timer_outlined,
                label: 'ETA to token',
                value: booking.estimatedWaitMinutes <= 0
                    ? 'Now'
                    : '${booking.estimatedWaitMinutes} min',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.scale_outlined,
                label: 'Pending weighing',
                value: pendingWeighing ? '1' : '0',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.fact_check_outlined,
                label: 'Pending quality',
                value: pendingQuality ? '1' : '0',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                icon: Icons.receipt_long_outlined,
                label: 'Pending billing',
                value: pendingBilling ? '1' : '0',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final status = booking.procurement.status;

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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StatusPill(status: status),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow('Token', booking.token),
            _InfoRow('Queue', '#${booking.queuePosition}'),
            _InfoRow('Slot', booking.queueState.slot),
            _InfoRow('Crop', booking.queueState.crop),
            _InfoRow('Quantity', '${booking.quantityQtl} QTL', isLast: true),
          ],
        ),
      ),
    );
  }

  Future<void> _processNextVehicle() async {
    final booking = _booking;
    if (booking == null || booking.queuePosition <= 1) return;

    try {
      final updatedQueue = QueueEngine.advanceQueue(booking.queueState);
      final updatedBooking = booking.copyWith(queueState: updatedQueue);
      final saved = await widget.repository.updateBooking(updatedBooking);

      if (!mounted) return;
      setState(() => _booking = saved);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Queue advanced: ${saved.token} is now #${saved.queuePosition}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update the queue.')),
      );
    }
  }

  Widget _buildQueueControl(Booking booking) {
    final canProcess = booking.queuePosition > 1;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Queue Control',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            canProcess
                ? 'Simulate one vehicle completing service before this token.'
                : 'This token is currently #1 and can enter gate processing.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          FilledButton.icon(
            onPressed: canProcess ? _processNextVehicle : null,
            icon: Icon(
              canProcess
                  ? Icons.fast_forward_rounded
                  : Icons.lock_open_rounded,
            ),
            label: Text(
              canProcess ? 'Process Next Vehicle' : 'Ready for Gate',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowSummary(Booking booking) {
    final status = booking.procurement.status;
    final complete = status == ProcurementStatus.paymentPaid;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: complete
            ? const Color(0xFFE8F5E9)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            complete
                ? Icons.check_circle_rounded
                : Icons.route_outlined,
            color: complete
                ? AppTheme.primaryGreen
                : AppTheme.accentOrange,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete ? 'Workflow complete' : 'Next operational step',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complete
                      ? 'Procurement and payment have reached the completed demo state.'
                      : _nextStep(status),
                  style: const TextStyle(
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

  String _nextStep(ProcurementStatus status) {
    switch (status) {
      case ProcurementStatus.awaitingGate:
        return 'Verify the farmer at the gate when token #1 arrives.';
      case ProcurementStatus.gateVerified:
        return 'Record the vehicle weighing.';
      case ProcurementStatus.weighingCompleted:
        return 'Complete the quality inspection.';
      case ProcurementStatus.qualityPassed:
        return 'Generate the procurement bill.';
      case ProcurementStatus.billGenerated:
        return 'Trigger the demo bank transfer.';
      case ProcurementStatus.bankTransferTriggered:
        return 'Complete the demo payment status.';
      case ProcurementStatus.paymentPaid:
        return 'No further action is required.';
    }
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No active booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'The staff queue is empty in this demo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ProcurementStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final paid = status == ProcurementStatus.paymentPaid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: paid
            ? const Color(0xFFE8F5E9)
            : AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: paid
              ? AppTheme.primaryGreen
              : AppTheme.accentOrange,
          fontSize: 8,
          fontWeight: FontWeight.w900,
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
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
