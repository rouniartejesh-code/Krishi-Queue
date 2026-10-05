import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_status.dart';
import '../domain/queue_engine.dart';
import '../domain/queue_status.dart';

class TrackQueueScreen extends StatefulWidget {
  final BookingRepository repository;

  const TrackQueueScreen({
    super.key,
    required this.repository,
  });

  @override
  State<TrackQueueScreen> createState() => _TrackQueueScreenState();
}

class _TrackQueueScreenState extends State<TrackQueueScreen> {
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

  Future<void> _simulateQueueMovement() async {
    final booking = _booking;

    if (booking == null ||
        booking.status != BookingStatus.confirmed) {
      return;
    }

    final updatedQueue = QueueEngine.advanceQueue(
      booking.queueState,
    );

    final updatedBooking = booking.copyWith(
      queueState: updatedQueue,
    );

    final savedBooking =
        await widget.repository.updateBooking(updatedBooking);

    if (!mounted) return;

    setState(() {
      _booking = savedBooking;
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
          title: const Text(
            'Track Queue',
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

    final queue = booking.queueState;

    final isYourTurn =
        queue.status == QueueStatus.yourTurnNext ||
        queue.queuePosition <= 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Queue',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBooking,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLiveHeader(isYourTurn),
                const SizedBox(height: 18),
                _buildQueuePosition(queue.queuePosition),
                const SizedBox(height: 16),
                _buildEtaCard(queue.estimatedWaitMinutes),
                const SizedBox(height: 20),
                _buildQueueProgress(queue.queuePosition),
                const SizedBox(height: 20),
                _buildQueueDetails(queue),
                const SizedBox(height: 20),
                _buildVisitStatus(queue, isYourTurn),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _simulateQueueMovement,
                  icon: const Icon(
                    Icons.sync_rounded,
                  ),
                  label: const Text(
                    'Simulate Queue Movement',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Demo control — live server updates will replace this later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveHeader(bool isYourTurn) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isYourTurn
            ? AppTheme.lightOrange
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isYourTurn
                  ? Icons.notifications_active_rounded
                  : Icons.sync_rounded,
              color: isYourTurn
                  ? AppTheme.accentOrange
                  : AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isYourTurn
                      ? 'YOUR TURN NEXT'
                      : 'QUEUE IS LIVE',
                  style: TextStyle(
                    color: isYourTurn
                        ? AppTheme.accentOrange
                        : AppTheme.primaryGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isYourTurn
                      ? 'Please be ready at the procurement centre.'
                      : 'Your queue position updates as vehicles are processed.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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

  Widget _buildQueuePosition(int position) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          22,
        ),
        child: Column(
          children: [
            const Text(
              'YOUR QUEUE POSITION',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '#$position',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'vehicles ahead of you',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtaCard(int etaMinutes) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(20),
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
              Icons.timer_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated wait',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Based on current queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$etaMinutes min',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueProgress(int position) {
    final current = position.clamp(1, 6);
    final progress = 1 - ((current - 1) / 5);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'QUEUE PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                Text(
                  'Live',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(
                  AppTheme.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProgressLabel(
                  title: 'Queue',
                  value: '#$position',
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: AppTheme.textSecondary,
                ),
                const _ProgressLabel(
                  title: 'Next',
                  value: 'Your turn',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueDetails(dynamic queue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUEUE DETAILS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.storefront_outlined,
                  label: 'Centre',
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
                  icon: Icons.access_time_rounded,
                  label: 'Slot',
                  value: queue.slot,
                ),
                _DetailRow(
                  icon: Icons.speed_rounded,
                  label: 'Avg. processing',
                  value:
                      '${queue.averageProcessingTimeMinutes} min / vehicle',
                ),
                _DetailRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Centre delay',
                  value:
                      '${queue.centreDelayBufferMinutes} min',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitStatus(dynamic queue, bool isYourTurn) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isYourTurn
                ? Icons.directions_car_filled_rounded
                : Icons.directions_car_outlined,
            color: isYourTurn
                ? AppTheme.accentOrange
                : AppTheme.primaryGreen,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isYourTurn
                      ? 'Be ready to proceed'
                      : 'Plan your arrival',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isYourTurn
                      ? 'Your token is approaching the processing position.'
                      : 'Use the live ETA to avoid unnecessary waiting at the centre.',
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
}

class _ProgressLabel extends StatelessWidget {
  final String title;
  final String value;

  const _ProgressLabel({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
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
        bottom: isLast ? 0 : 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
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