import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_status.dart';
import '../../procurement/domain/procurement_status.dart';

class BookingsScreen extends StatefulWidget {
  final BookingRepository repository;
  final VoidCallback? onBookSlot;
  final ValueChanged<Booking>? onBookingTap;

  const BookingsScreen({
    super.key,
    required this.repository,
    this.onBookSlot,
    this.onBookingTap,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  Booking? _booking;
  bool _loading = true;
  bool _updating = false;

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
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load booking: $error'),
        ),
      );
    }
  }

  Future<void> _cancelBooking() async {
    if (_updating) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Cancel Booking?',
      message:
          'Are you sure you want to cancel this procurement booking?',
      confirmLabel: 'Cancel Booking',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _updating = true;
    });

    try {
      final updatedBooking =
          await widget.repository.cancelBooking();

      if (!mounted) return;

      setState(() {
        _booking = updatedBooking;
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking cancelled successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not cancel booking: $error',
          ),
        ),
      );
    }
  }

  Future<void> _completeBooking() async {
    if (_updating) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Complete Booking?',
      message:
          'Mark this procurement booking as completed?',
      confirmLabel: 'Complete Booking',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _updating = true;
    });

    try {
      final updatedBooking =
          await widget.repository.completeBooking();

      if (!mounted) return;

      setState(() {
        _booking = updatedBooking;
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking completed successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not complete booking: $error',
          ),
        ),
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Go Back'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _booking == null
              ? _EmptyBookings(
                  onBookSlot: widget.onBookSlot,
                )
              : RefreshIndicator(
                  onRefresh: _loadBooking,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      28,
                    ),
                    children: [
                      const Text(
                        'Current Booking',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _BookingCard(
                        booking: _booking!,
                        onTap: () {
                          widget.onBookingTap?.call(
                            _booking!,
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _DetailsCard(
                        booking: _booking!,
                      ),

                      const SizedBox(height: 26),

                      const Text(
                        'Status Timeline',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _TimelineCard(
                        booking: _booking!,
                      ),

                      const SizedBox(height: 22),

                      if (_booking!.status ==
                          BookingStatus.confirmed)
                        _buildBookingActions(),

                      if (_booking!.status ==
                          BookingStatus.confirmed)
                        const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: widget.onBookSlot,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                        ),
                        label: const Text(
                          'Book Another Slot',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBookingActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _updating || _booking?.procurement.status != ProcurementStatus.paymentPaid
              ? null
              : _completeBooking,
          icon: _updating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.check_circle_outline_rounded,
                ),
          label: Text(
            _updating
                ? 'Updating...'
                : 'Complete practice booking after payment',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed:
              _updating || _booking?.procurement.status != ProcurementStatus.awaitingGate ? null : _cancelBooking,
          icon: const Icon(
            Icons.cancel_outlined,
          ),
          label: const Text(
            'Cancel Booking',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final queue = booking.queueState;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: AppTheme.accentOrange,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bookingNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          queue.token,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon:
                          Icons.storefront_outlined,
                      label: 'Centre',
                      value: queue.centre,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInfo(
                      icon:
                          Icons.agriculture_outlined,
                      label: 'Crop',
                      value: queue.crop,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      icon:
                          Icons.calendar_today_outlined,
                      label: 'Date',
                      value: queue.deliveryDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniInfo(
                      icon:
                          Icons.access_time_outlined,
                      label: 'Slot',
                      value: queue.slot,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: booking.status ==
                          BookingStatus.cancelled
                      ? const Color(0xFFFFEBEE)
                      : booking.status ==
                              BookingStatus.completed
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      booking.status ==
                              BookingStatus.cancelled
                          ? Icons.cancel_outlined
                          : booking.status ==
                                  BookingStatus.completed
                              ? Icons.check_circle_outline
                              : Icons
                                  .people_outline_rounded,
                      size: 18,
                      color: booking.status ==
                              BookingStatus.cancelled
                          ? Colors.red.shade700
                          : AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking.status ==
                              BookingStatus.confirmed
                          ? 'Queue #${queue.queuePosition}'
                          : booking.status ==
                                  BookingStatus.completed
                              ? 'Procurement completed'
                              : 'Booking cancelled',
                      style: TextStyle(
                        color: booking.status ==
                                BookingStatus.cancelled
                            ? Colors.red.shade700
                            : AppTheme.primaryGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    if (booking.status ==
                        BookingStatus.confirmed) ...[
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ETA ${queue.estimatedWaitMinutes} min',
                        style: const TextStyle(
                          color:
                              AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _StatusBadge(
                      status: booking.status,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Booking booking;

  const _DetailsCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final queue = booking.queueState;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _DetailRow(
              icon:
                  Icons.confirmation_number_outlined,
              label: 'Booking Number',
              value: booking.bookingNumber,
            ),
            _DetailRow(
              icon: Icons.qr_code_2_rounded,
              label: 'Token',
              value: queue.token,
            ),
            _DetailRow(
              icon: Icons.storefront_outlined,
              label: 'Procurement Centre',
              value: queue.centre,
            ),
            _DetailRow(
              icon: Icons.agriculture_outlined,
              label: 'Crop',
              value: queue.crop,
            ),
            _DetailRow(
              icon: Icons.scale_outlined,
              label: 'Quantity',
              value:
                  '${queue.quantityQuintals} Quintals',
            ),
            _DetailRow(
              icon:
                  Icons.calendar_today_outlined,
              label: 'Delivery Date',
              value: queue.deliveryDate,
            ),
            _DetailRow(
              icon: Icons.access_time_outlined,
              label: 'Slot',
              value: queue.slot,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Booking booking;

  const _TimelineCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final history = booking.statusHistory;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (int i = 0;
                i < history.length;
                i++)
              _TimelineItem(
                status: history[i].status,
                timestamp: history[i].timestamp,
                isLast:
                    i == history.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final BookingStatus status;
  final DateTime timestamp;
  final bool isLast;

  const _TimelineItem({
    required this.status,
    required this.timestamp,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cancelled =
        status == BookingStatus.cancelled;

    final completed =
        status == BookingStatus.completed;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: cancelled
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  cancelled
                      ? Icons.cancel_outlined
                      : completed
                          ? Icons.check_circle_rounded
                          : Icons.event_available_rounded,
                  size: 17,
                  color: cancelled
                      ? Colors.red.shade700
                      : AppTheme.primaryGreen,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 42,
                  margin:
                      const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  color: Colors.grey.shade200,
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(timestamp),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${_month(dateTime.month)} '
        '${dateTime.year} • $hour:$minute $period';
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 17,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cancelled =
        status == BookingStatus.cancelled;

    final completed =
        status == BookingStatus.completed;

    final background = cancelled
        ? const Color(0xFFFFEBEE)
        : completed
            ? const Color(0xFFE8F5E9)
            : AppTheme.lightOrange;

    final foreground = cancelled
        ? Colors.red.shade700
        : completed
            ? AppTheme.primaryGreen
            : AppTheme.accentOrange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        completed
            ? 'COMPLETED'
            : cancelled
                ? 'CANCELLED'
                : 'ACTIVE',
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  final VoidCallback? onBookSlot;

  const _EmptyBookings({
    required this.onBookSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 70),

        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius:
                  BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 42,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          'No bookings yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Book a procurement slot to get your digital token.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: onBookSlot,
          icon: const Icon(
            Icons.calendar_month_rounded,
          ),
          label: const Text(
            'Book Slot',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
