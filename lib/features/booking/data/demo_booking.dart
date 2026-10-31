import '../domain/booking.dart';
import '../domain/booking_status.dart';
import '../domain/booking_status_event.dart';
import '../../procurement/domain/procurement_state.dart';
import '../../queue/domain/queue_state.dart';
import '../../queue/domain/queue_status.dart';

final _demoDeliveryDate = DateTime.now().add(const Duration(days: 1));
final _demoDeliveryDateLabel =
    '${_demoDeliveryDate.day} ${_monthNames[_demoDeliveryDate.month - 1]} '
    '${_demoDeliveryDate.year}';

const _monthNames = [
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

final demoBooking = Booking(
  bookingNumber: 'BK-2026-000124',
  farmerId: 'FARMER-DEMO-001',
  centreId: 'CENTRE-DEMO-001',
  cropId: 'CROP-PADDY',
  slotId: 'SLOT-1030-1200',
  quantityQtl: 25,
  deliveryDate: _demoDeliveryDateLabel,
  status: BookingStatus.confirmed,
  queueState: QueueState(
    token: 'KQ-2026-000124',
    centre: 'Krishi Seva Kendra',
    crop: 'Paddy',
    quantityQuintals: 25,
    deliveryDate: _demoDeliveryDateLabel,
    slot: '10:30 AM – 12:00 PM',
    queuePosition: 6,
    averageProcessingTimeMinutes: 6,
    centreDelayBufferMinutes: 6,
    status: QueueStatus.bookingConfirmed,
  ),
  statusHistory: [
    BookingStatusEvent(
      status: BookingStatus.confirmed,
      timestamp: DateTime.now(),
    ),
  ],
  procurement: const ProcurementState(
    marketReferenceModalPricePerQtl: 2250,
    procurementRatePerQtl: 2200,
  ),
);
