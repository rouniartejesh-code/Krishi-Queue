import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../../booking/domain/booking_status.dart';
import '../../booking/presentation/bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  final BookingRepository repository;
  final VoidCallback? onBookSlot;
  final VoidCallback? onTokenTap;
  final VoidCallback? onTrackQueueTap;
  final VoidCallback? onMarketPriceTap;
  final VoidCallback? onPaymentTap;
  final VoidCallback? onLogout;
  final Widget? newsScreen;
  final Widget? chatScreen;

  const HomeScreen({
    super.key,
    required this.repository,
    this.onBookSlot,
    this.onTokenTap,
    this.onTrackQueueTap,
    this.onMarketPriceTap,
    this.onPaymentTap,
    this.onLogout,
    this.newsScreen,
    this.chatScreen,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            widget.newsScreen ?? const SizedBox.shrink(),
            widget.chatScreen ?? const SizedBox.shrink(),
            BookingsScreen(
              repository: widget.repository,
              onBookSlot: widget.onBookSlot,
              onBookingTap: (_) {
                widget.onTokenTap?.call();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper_rounded),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadBooking,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildBookingCard(),
            const SizedBox(height: 20),
            _buildQuickServices(),
            const SizedBox(height: 20),
            _buildInformationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Namaste, Farmer',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Krishi Queue',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Switch role',
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard() {
    if (_loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 14),
              Text(
                'Loading your booking...',
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

    if (_booking == null) {
      return _buildNoBookingCard();
    }

    final booking = _booking!;

    if (booking.status != BookingStatus.confirmed) {
      return _buildNoBookingCard();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'MY TOKEN',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.label,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              booking.token,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Queue',
                    value: '#${booking.queuePosition}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    icon: Icons.schedule_rounded,
                    label: 'ETA',
                    value: '${booking.estimatedWaitMinutes} min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            const Divider(height: 1),
            const SizedBox(height: 15),
            _BookingInfoRow(
              icon: Icons.storefront_outlined,
              value: booking.queueState.centre,
            ),
            const SizedBox(height: 9),
            _BookingInfoRow(
              icon: Icons.agriculture_outlined,
              value:
                  '${booking.queueState.crop} • ${booking.quantityQtl} QTL',
            ),
            const SizedBox(height: 9),
            _BookingInfoRow(
              icon: Icons.access_time_rounded,
              value: booking.queueState.slot,
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: widget.onTokenTap,
              icon: const Icon(
                Icons.qr_code_2_rounded,
              ),
              label: const Text(
                'View Token & Track Queue',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBookingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 29,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Active Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Book a procurement slot to get your digital token.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 17),
            FilledButton.icon(
              onPressed: widget.onBookSlot,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Book Procurement Slot',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Services',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ServiceTile(
                icon: Icons.add_box_outlined,
                title: 'Book Slot',
                onTap: widget.onBookSlot,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ServiceTile(
                icon: Icons.qr_code_2_rounded,
                title: 'My Token',
                onTap: widget.onTokenTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ServiceTile(
                icon: Icons.track_changes_outlined,
                title: 'Track Queue',
                onTap: widget.onTrackQueueTap,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _ServiceTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Market Price',
                onTap: widget.onMarketPriceTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ServiceTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment',
                onTap: widget.onPaymentTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ServiceTile(
                icon: Icons.help_outline_rounded,
                title: 'Help',
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.accentOrange,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan your visit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Book a slot before arriving at the procurement centre to reduce waiting time.',
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
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _BookingInfoRow({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 15,
          ),
          child: Column(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 21,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}