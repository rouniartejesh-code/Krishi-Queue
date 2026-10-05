import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';

class DriverDashboardScreen extends StatefulWidget {
  final BookingRepository repository;
  final VoidCallback? onLogout;

  const DriverDashboardScreen({
    super.key,
    required this.repository,
    this.onLogout,
  });

  @override
  State<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  Booking? _booking;
  bool _loading = true;
  bool _arrived = false;

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
        _arrived = booking.driverArrived;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _markArrived() async {
    final booking = _booking;
    if (booking == null || _arrived || !booking.driverAssigned) return;

    try {
      final updated = booking.copyWith(driverArrived: true);
      final saved = await widget.repository.updateBooking(updated);

      if (!mounted) return;
      setState(() {
        _booking = saved;
        _arrived = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to record driver arrival.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver Operations',
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
              const Center(child: Text('No booking assigned.'))
            else ...[
              _bookingCard(booking),
              const SizedBox(height: 16),
              _arrivalCard(booking),
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
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_shipping_rounded, color: AppTheme.accentOrange),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DRIVER DEMO MODE',
                  style: TextStyle(
                    color: AppTheme.accentOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This driver view reads the same local demo booking used by the other roles.',
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

  Widget _bookingCard(Booking booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assigned Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _InfoRow('Booking', booking.bookingNumber),
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

  Widget _arrivalCard(Booking booking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _arrived ? 'Arrival confirmed' : booking.driverAssigned ? 'Arrival status' : 'Awaiting assignment',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _arrived
                  ? 'Driver has marked arrival for ${booking.token}.'
                  : booking.driverAssigned
                      ? 'Mark arrival when the assigned vehicle reaches the centre.'
                      : 'Staff has not assigned a driver to this booking yet.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: !_arrived && booking.driverAssigned ? _markArrived : null,
              icon: Icon(
                _arrived ? Icons.check_rounded : Icons.location_on_outlined,
              ),
              label: Text(_arrived ? 'Arrival Recorded' : booking.driverAssigned ? 'Mark Arrived' : 'Awaiting Assignment'),
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
