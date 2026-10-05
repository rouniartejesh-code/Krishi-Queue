import '../domain/booking.dart';
import '../domain/booking_status.dart';
import '../domain/booking_status_event.dart';
import '../../procurement/domain/procurement_state.dart';
import '../../queue/domain/queue_state.dart';
import '../../queue/domain/queue_status.dart';

final demoBooking = Booking(
  bookingNumber: 'BK-2026-000124',
  farmerId: 'FARMER-DEMO-001',
  centreId: 'CENTRE-DEMO-001',
  cropId: 'CROP-PADDY',
  slotId: 'SLOT-1030-1200',
  quantityQtl: 25,
  deliveryDate: '12 September 2026',
  status: BookingStatus.confirmed,
  queueState: const QueueState(
    token: 'KQ-2026-000124',
    centre: 'Krishi Seva Kendra',
    crop: 'Paddy',
    quantityQuintals: 25,
    deliveryDate: '12 September 2026',
    slot: '10:30 AM – 12:00 PM',
    queuePosition: 6,
    averageProcessingTimeMinutes: 6,
    centreDelayBufferMinutes: 6,
    status: QueueStatus.bookingConfirmed,
  ),
  statusHistory: [
    BookingStatusEvent(
      status: BookingStatus.confirmed,
      timestamp: DateTime(2026, 9, 12, 9, 30),
    ),
  ],
  procurement: const ProcurementState(
    marketReferenceModalPricePerQtl: 2250,
    procurementRatePerQtl: 2200,
  ),
);
