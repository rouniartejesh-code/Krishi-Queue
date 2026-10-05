import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../procurement/domain/procurement_status.dart';

class AdminDashboardScreen extends StatefulWidget {
  final BookingRepository repository;
  final VoidCallback? onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.repository,
    this.onLogout,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Booking? _booking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    if (mounted) setState(() => _loading = true);
    try {
      final booking = await widget.repository.getBooking();
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final status = booking?.procurement.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Monitor',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
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
            _banner(),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (booking == null)
              const Center(child: Text('No active booking.'))
            else ...[
              _metrics(booking),
              const SizedBox(height: 20),
              _bookingCard(booking),
              const SizedBox(height: 16),
              _statusCard(status!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryGreen),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN DEMO MONITOR',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Operational metrics below are derived from the shared local demo booking.',
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

  Widget _metrics(Booking booking) {
    final status = booking.procurement.status;
    final waiting = booking.queuePosition > 1 ? booking.queuePosition - 1 : 0;
    final paid = status == ProcurementStatus.paymentPaid ? 1 : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Bookings',
                value: '1',
                icon: Icons.event_note_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                label: 'Waiting',
                value: '$waiting',
                icon: Icons.people_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Queue load',
                value: '${booking.queuePosition}',
                icon: Icons.stacked_bar_chart_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                label: 'Paid',
                value: '$paid',
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bookingCard(Booking booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 13),
            _InfoRow('Booking', booking.bookingNumber),
            _InfoRow('Token', booking.token),
            _InfoRow('Farmer', booking.farmerId),
            _InfoRow('Centre', booking.queueState.centre),
            _InfoRow('Crop', booking.queueState.crop),
            _InfoRow('Quantity', '${booking.quantityQtl} QTL', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(ProcurementStatus status) {
    final paid = status == ProcurementStatus.paymentPaid;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFE8F5E9) : AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            paid ? Icons.check_circle_rounded : Icons.sync_rounded,
            color: paid ? AppTheme.primaryGreen : AppTheme.accentOrange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Procurement status',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: paid
                        ? AppTheme.primaryGreen
                        : AppTheme.accentOrange,
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

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: AppTheme.primaryGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
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
