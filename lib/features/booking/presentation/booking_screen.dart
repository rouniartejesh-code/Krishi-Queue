import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../market/data/market_price_repository.dart';

import '../domain/booking_creator.dart';
import '../domain/booking_repository.dart';

class BookingScreen extends StatefulWidget {
  final BookingRepository repository;
  final MarketPriceRepository? marketPriceRepository;
  final VoidCallback? onBookingConfirmed;

  const BookingScreen({
    super.key,
    required this.repository,
    this.marketPriceRepository,
    this.onBookingConfirmed,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;

  String? _selectedCentre;
  String? _selectedCrop;
  int _quantity = 25;
  DateTime _selectedDate = _today;
  String? _selectedSlot;

  bool _showRecommendation = true;
  bool _booking = false;

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  final List<_CentreOption> _centres = const [
    _CentreOption(
      name: 'Krishi Seva Kendra',
      location: 'Main Procurement Centre',
      distance: '2.4 km',
      load: 'Low',
      capacity: '18 / 40 vehicles',
      id: 'CENTRE-DEMO-001',
    ),
    _CentreOption(
      name: 'Kisan Procurement Centre',
      location: 'Block Office Road',
      distance: '5.8 km',
      load: 'Medium',
      capacity: '29 / 40 vehicles',
      id: 'CENTRE-DEMO-002',
    ),
    _CentreOption(
      name: 'Mandi Procurement Yard',
      location: 'Agricultural Mandi',
      distance: '8.1 km',
      load: 'High',
      capacity: '37 / 40 vehicles',
      id: 'CENTRE-DEMO-003',
    ),
  ];

  final List<String> _crops = const [
    'Paddy',
    'Wheat',
    'Maize',
    'Soybean',
    'Gram',
  ];

  final List<_SlotOption> _slots = const [
    _SlotOption(time: '08:00 AM – 09:30 AM', remaining: 7, load: 'Low'),
    _SlotOption(
      time: '10:30 AM – 12:00 PM',
      remaining: 14,
      load: 'Low',
      recommended: true,
    ),
    _SlotOption(time: '12:30 PM – 02:00 PM', remaining: 9, load: 'Medium'),
    _SlotOption(time: '03:00 PM – 04:30 PM', remaining: 3, load: 'High'),
  ];

  List<_SlotOption> get _availableSlots {
    final today = _today;
    final isToday =
        _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    if (!isToday) return _slots;

    final now = DateTime.now();
    return _slots.where((slot) {
      final startLabel = slot.time.split(' – ').first;
      final match = RegExp(r'^(\d{1,2}):(\d{2})\s+(AM|PM)$')
          .firstMatch(startLabel);
      if (match == null) return false;

      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!;
      if (period == 'AM' && hour == 12) hour = 0;
      if (period == 'PM' && hour != 12) hour += 12;

      final startsAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );
      return startsAt.isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Procurement Slot',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    const labels = ['Centre', 'Crop', 'Quantity', 'Date', 'Slot', 'Confirm'];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      color: AppTheme.background,
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length, (index) {
              final active = index <= _step;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (index != labels.length - 1) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 9),
          Row(
            children: List.generate(labels.length, (index) {
              return Expanded(
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: index == _step
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: index == _step
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildCentreStep();
      case 1:
        return _buildCropStep();
      case 2:
        return _buildQuantityStep();
      case 3:
        return _buildDateStep();
      case 4:
        return _buildSlotStep();
      case 5:
        return _buildConfirmStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCentreStep() {
    return _StepContainer(
      key: const ValueKey('centre'),
      title: 'Select Procurement Centre',
      subtitle: 'Choose the centre where you want to deliver your crop.',
      child: Column(
        children: [
          for (final centre in _centres)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CentreCard(
                option: centre,
                selected: _selectedCentre == centre.name,
                onTap: () {
                  setState(() {
                    _selectedCentre = centre.name;
                  });
                },
              ),
            ),
          _NavigationButtons(
            showBack: false,
            canContinue: _selectedCentre != null,
            onBack: () {},
            onNext: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildCropStep() {
    return _StepContainer(
      key: const ValueKey('crop'),
      title: 'Select Your Crop',
      subtitle: 'Choose the crop you are bringing for procurement.',
      child: Column(
        children: [
          for (final crop in _crops)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectionTile(
                icon: Icons.agriculture_outlined,
                title: crop,
                selected: _selectedCrop == crop,
                onTap: () {
                  setState(() {
                    _selectedCrop = crop;
                  });
                },
              ),
            ),
          _NavigationButtons(
            canContinue: _selectedCrop != null,
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStep() {
    return _StepContainer(
      key: const ValueKey('quantity'),
      title: 'Enter Quantity',
      subtitle: 'Tell us approximately how much crop you will bring.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Expected Quantity',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_quantity QTL',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Quintals',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onTap: _quantity > 5
                            ? () {
                                setState(() {
                                  _quantity -= 5;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 18),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onTap: _quantity < 100
                            ? () {
                                setState(() {
                                  _quantity += 5;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _InfoBanner(
            icon: Icons.info_outline_rounded,
            text: 'Quantity helps estimate processing time and improve slot recommendations.',
          ),
          const SizedBox(height: 20),
          _NavigationButtons(canContinue: true, onBack: _back, onNext: _next),
        ],
      ),
    );
  }

  Widget _buildDateStep() {
    return _StepContainer(
      key: const ValueKey('date'),
      title: 'Choose Delivery Date',
      subtitle: 'Select the date when you plan to visit the centre.',
      child: Column(
        children: [
          Card(
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: _today,
              lastDate: DateTime(_today.year + 1, _today.month, _today.day),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedSlot = null;
                });
              },
            ),
          ),
          const SizedBox(height: 14),
          _InfoBanner(
            icon: Icons.calendar_today_outlined,
            text: 'Selected: ${_formatDate(_selectedDate)}',
          ),
          const SizedBox(height: 20),
          _NavigationButtons(canContinue: true, onBack: _back, onNext: _next),
        ],
      ),
    );
  }

  Widget _buildSlotStep() {
    return _StepContainer(
      key: const ValueKey('slot'),
      title: 'Choose a Time Slot',
      subtitle: 'Pick a slot that works best for your delivery.',
      child: Column(
        children: [
          if (_showRecommendation)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RecommendationCard(
                onClose: () {
                  setState(() {
                    _showRecommendation = false;
                  });
                },
              ),
            ),
          if (_availableSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No delivery slots remain today. Choose another date.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final slot in _availableSlots)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SlotCard(
                  option: slot,
                  selected: _selectedSlot == slot.time,
                  onTap: () {
                    setState(() {
                      _selectedSlot = slot.time;
                    });
                  },
                ),
              ),
          _NavigationButtons(
            canContinue: _availableSlots.any(
              (slot) => slot.time == _selectedSlot,
            ),
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return _StepContainer(
      key: const ValueKey('confirm'),
      title: 'Confirm Your Booking',
      subtitle: 'Review your details before reserving the procurement slot.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _SummaryRow(label: 'Centre', value: _selectedCentre ?? '-'),
                  _SummaryRow(label: 'Crop', value: _selectedCrop ?? '-'),
                  _SummaryRow(label: 'Quantity', value: '$_quantity QTL'),
                  _SummaryRow(label: 'Date', value: _formatDate(_selectedDate)),
                  _SummaryRow(
                    label: 'Time Slot',
                    value: _selectedSlot ?? '-',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _InfoBanner(
            icon: Icons.verified_outlined,
            text: 'After confirmation, your digital procurement token will be generated and saved to your booking.',
          ),
          const SizedBox(height: 20),
          _NavigationButtons(
            canContinue: !_booking,
            nextLabel: _booking ? 'Confirming...' : 'Confirm Booking',
            onBack: _booking ? null : _back,
            onNext: _confirmBooking,
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_step < 5) {
      setState(() {
        _step++;
      });
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_booking) return;

    final centreName = _selectedCentre;
    final cropName = _selectedCrop;
    final slot = _selectedSlot;

    if (centreName == null || cropName == null || slot == null) {
      return;
    }

    setState(() {
      _booking = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      final centre = _centres.firstWhere((item) => item.name == centreName);

      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();

      final bookingNumber =
          'BK-${DateTime.now().year}-${bookingId.substring(7)}';

      final token = 'KQ-${DateTime.now().year}-${bookingId.substring(7)}';

      await BookingCreator.create(
        repository: widget.repository,
        farmerId: 'FARMER-DEMO-001',
        centreId: centre.id,
        cropId: _toId(cropName),
        slotId: _toSlotId(slot),
        quantityQtl: _quantity,
        deliveryDate: _formatDate(_selectedDate),
        bookingNumber: bookingNumber,
        token: token,
        centre: centreName,
        crop: cropName,
        slot: slot,
        queuePosition: 6,
        averageProcessingTimeMinutes: _processingTimeForQuantity(_quantity),
        centreDelayBufferMinutes: 6,
        marketReferenceModalPricePerQtl: null,
      );

      if (!mounted) return;

      setState(() {
        _booking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed successfully.')),
      );

      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;

      widget.onBookingConfirmed?.call();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _booking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not confirm booking: $error')),
      );
    }
  }

  int _processingTimeForQuantity(int quantity) {
    if (quantity <= 25) return 6;
    if (quantity <= 50) return 8;
    if (quantity <= 75) return 10;
    return 12;
  }

  String _toId(String value) {
    return 'CROP-${value.toUpperCase().replaceAll(' ', '-')}';
  }

  String _toSlotId(String value) {
    return 'SLOT-${value.replaceAll(' ', '').replaceAll('–', '-').replaceAll(':', '').replaceAll('AM', 'A').replaceAll('PM', 'P')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _StepContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _CentreOption {
  final String name;
  final String location;
  final String distance;
  final String load;
  final String capacity;
  final String id;

  const _CentreOption({
    required this.name,
    required this.location,
    required this.distance,
    required this.load,
    required this.capacity,
    required this.id,
  });
}

class _SlotOption {
  final String time;
  final int remaining;
  final String load;
  final bool recommended;

  const _SlotOption({
    required this.time,
    required this.remaining,
    required this.load,
    this.recommended = false,
  });
}

class _CentreCard extends StatelessWidget {
  final _CentreOption option;
  final bool selected;
  final VoidCallback onTap;

  const _CentreCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: selected
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.location,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          option.distance,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _LoadBadge(load: option.load),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppTheme.primaryGreen : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppTheme.primaryGreen : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final _SlotOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SlotCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: selected
                      ? AppTheme.primaryGreen
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.time,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (option.recommended) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightOrange,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                color: AppTheme.accentOrange,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${option.remaining} slots left',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _LoadBadge(load: option.load),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppTheme.primaryGreen : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final VoidCallback onClose;

  const _RecommendationCard({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentOrange.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_outlined, color: AppTheme.accentOrange),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Slot Recommendation',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                SizedBox(height: 5),
                Text(
                  '10:30 AM – 12:00 PM is recommended because the current centre load is low and more capacity is available.',
                  style: TextStyle(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _LoadBadge extends StatelessWidget {
  final String load;

  const _LoadBadge({required this.load});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: load == 'Low'
            ? const Color(0xFFE8F5E9)
            : load == 'Medium'
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        load,
        style: TextStyle(
          color: load == 'Low'
              ? AppTheme.primaryGreen
              : load == 'Medium'
              ? Colors.orange.shade800
              : Colors.red.shade700,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBanner({required this.icon, required this.text});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? Colors.grey.shade100 : AppTheme.primaryGreen,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 54,
          height: 50,
          child: Icon(
            icon,
            color: onTap == null ? Colors.grey.shade400 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final bool showBack;
  final bool canContinue;
  final String nextLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const _NavigationButtons({
    this.showBack = true,
    required this.canContinue,
    this.nextLabel = 'Continue',
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (showBack) const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: canContinue ? onNext : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              nextLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
