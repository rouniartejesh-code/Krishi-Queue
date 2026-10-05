import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_engine.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_status.dart';
import '../domain/procurement_engine.dart';
import '../domain/procurement_status.dart';

class ProcurementScreen extends StatefulWidget {
  final BookingRepository repository;

  const ProcurementScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ProcurementScreen> createState() =>
      _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  Booking? _booking;
  bool _loading = true;
  bool _advancing = false;
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

final gateLocked =
    booking.procurement.status ==
        ProcurementStatus.awaitingGate &&
    booking.queueState.queuePosition > 1;

setState(() {
  _booking = booking;
  _loading = false;
  _errorMessage = gateLocked
      ? 'Gate verification is locked. Your queue position is '
          '#${booking.queueState.queuePosition}. Reach #1 to continue.'
      : null;
});
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _advanceWorkflow() async {
    final booking = _booking;

    if (booking == null || _advancing) {
      return;
    }

    final status = booking.procurement.status;

    if (!ProcurementEngine.canAdvance(status)) {
      return;
    }

    if (status == ProcurementStatus.awaitingGate &&
        booking.queueState.queuePosition > 1) {
      setState(() {
        _errorMessage =
            'Gate verification is locked. Your queue position is '
            '#${booking.queueState.queuePosition}. Reach #1 to continue.';
      });
      return;
    }

    setState(() {
      _advancing = true;
      _errorMessage = null;
    });

    try {
      var updatedBooking =
          ProcurementEngine.advance(booking);

      if (updatedBooking.procurement.status ==
              ProcurementStatus.paymentPaid &&
          updatedBooking.status != BookingStatus.completed) {
        updatedBooking =
            BookingEngine.complete(updatedBooking);
      }

      final saved =
          await widget.repository.updateBooking(
        updatedBooking,
      );

      if (!mounted) return;

      setState(() {
        _booking = saved;
        _advancing = false;
        _errorMessage = null;
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
    final message =
        error.toString().replaceFirst('Bad state: ', '');

    if (message.contains('queue position is #1')) {
      final booking = _booking;
      final position =
          booking?.queueState.queuePosition;

      if (position != null && position > 1) {
        return 'Gate verification is locked. Your queue position is '
            '#$position. Reach #1 to continue.';
      }
    }

    return message;
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
          title: const Text(
            'Procurement Status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: Text('No booking found.'),
        ),
      );
    }

    final status = booking.procurement.status;

    final gateLocked =
        status == ProcurementStatus.awaitingGate &&
            booking.queueState.queuePosition > 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Procurement Status',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBooking,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ),
          children: [
            if (_errorMessage != null) ...[
              _buildErrorBanner(
                _errorMessage!,
              ),
              const SizedBox(height: 12),
            ],

            _buildBookingHeader(booking),

            const SizedBox(height: 16),

            _buildStatusCard(status),

            const SizedBox(height: 20),

            const Text(
              'Procurement Journey',
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

            if (status !=
                ProcurementStatus.paymentPaid)
              FilledButton.icon(
                onPressed:
                    _advancing || gateLocked
                        ? null
                        : _advanceWorkflow,
                icon: _advancing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        gateLocked
                            ? Icons.lock_outline_rounded
                            : Icons
                                .fast_forward_rounded,
                      ),
                label: Text(
                  _advancing
                      ? 'Updating...'
                      : gateLocked
                          ? 'Reach Queue #1 to Continue'
                          : 'Simulate Next Step',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                          AppTheme.primaryGreen,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Procurement and payment '
                        'workflow completed.',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
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

  Widget _buildErrorBanner(
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentOrange
              .withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.accentOrange,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action unavailable',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color:
                        AppTheme.textSecondary,
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
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
            ),
            visualDensity:
                VisualDensity.compact,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(
    Booking booking,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration:
                      BoxDecoration(
                    color:
                        AppTheme.lightOrange,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .agriculture_rounded,
                    color:
                        AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Booking',
                        style: TextStyle(
                          color: AppTheme
                              .textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        booking.bookingNumber,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              'Centre',
              booking.queueState.centre,
            ),
            _InfoRow(
              'Crop',
              booking.queueState.crop,
            ),
            _InfoRow(
              'Quantity',
              '${booking.quantityQtl} QTL',
            ),
            _InfoRow(
              'Token',
              booking.token,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    ProcurementStatus status,
  ) {
    final paid =
        status == ProcurementStatus.paymentPaid;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: paid
            ? const Color(0xFFE8F5E9)
            : AppTheme.lightOrange,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: paid
                  ? AppTheme.primaryGreen
                  : AppTheme.accentOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              paid
                  ? Icons.check_rounded
                  : Icons.sync_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    color:
                        AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                    color: paid
                        ? AppTheme
                            .primaryGreen
                        : AppTheme
                            .accentOrange,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.description,
                  style: const TextStyle(
                    color:
                        AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(
    ProcurementStatus current,
  ) {
    const stages = [
      _Stage(
        'Gate Verification',
        ProcurementStatus.gateVerified,
      ),
      _Stage(
        'Weighing',
        ProcurementStatus.weighingCompleted,
      ),
      _Stage(
        'Quality Check',
        ProcurementStatus.qualityPassed,
      ),
      _Stage(
        'Bill Generated',
        ProcurementStatus.billGenerated,
      ),
      _Stage(
        'Bank Transfer',
        ProcurementStatus.bankTransferTriggered,
      ),
      _Stage(
        'PAID',
        ProcurementStatus.paymentPaid,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          8,
        ),
        child: Column(
          children: [
            _TimelineRow(
              title: 'Booking Confirmed',
              done: true,
              active:
                  current ==
                      ProcurementStatus.awaitingGate,
              isLast: false,
            ),
            for (var i = 0;
                i < stages.length;
                i++)
              _TimelineRow(
                title: stages[i].title,
                done:
                    current.index >=
                        stages[i].status.index,
                active:
                    current ==
                        stages[i].status,
                isLast:
                    i == stages.length - 1,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecords(
    Booking booking,
  ) {
    final p = booking.procurement;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Procurement Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 13),

            _InfoRow(
              'Market reference',
              p.marketReferenceModalPricePerQtl ==
                      null
                  ? 'Not available'
                  : '₹${p.marketReferenceModalPricePerQtl!.toStringAsFixed(0)} / QTL',
            ),

            _InfoRow(
              'Demo procurement rate',
              p.procurementRatePerQtl ==
                      null
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

            _InfoRow(
              'Quality grade',
              p.qualityGrade ?? 'Pending',
            ),

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
}

class _Stage {
  final String title;
  final ProcurementStatus status;

  const _Stage(
    this.title,
    this.status,
  );
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
                  done
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 17,
                  color: done
                      ? Colors.white
                      : AppTheme.textSecondary,
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
            padding:
                const EdgeInsets.only(
              top: 5,
              bottom: 20,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    done || active
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
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 11,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color:
                    AppTheme.textSecondary,
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
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}