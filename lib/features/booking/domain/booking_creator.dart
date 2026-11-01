import 'booking.dart';
import 'booking_repository.dart';
import 'booking_status.dart';
import 'booking_status_event.dart';
import '../../procurement/domain/procurement_state.dart';
import '../../queue/domain/queue_state.dart';
import '../../queue/domain/queue_status.dart';

class BookingCreator {
  static Future<Booking> create({
    required BookingRepository repository,
    required String farmerId,
    required String centreId,
    required String cropId,
    required String slotId,
    required int quantityQtl,
    required String deliveryDate,
    required String bookingNumber,
    required String token,
    required String centre,
    required String crop,
    required String slot,
    required int queuePosition,
    required int averageProcessingTimeMinutes,
    required int centreDelayBufferMinutes,
    double? marketReferenceModalPricePerQtl,
    double? procurementRatePerQtl,
  }) async {
    final booking = Booking(
      bookingNumber: bookingNumber,
      farmerId: farmerId,
      centreId: centreId,
      cropId: cropId,
      slotId: slotId,
      quantityQtl: quantityQtl,
      deliveryDate: deliveryDate,
      status: BookingStatus.confirmed,
      queueState: QueueState(
        token: token,
        centre: centre,
        crop: crop,
        quantityQuintals: quantityQtl,
        deliveryDate: deliveryDate,
        slot: slot,
        queuePosition: queuePosition,
        averageProcessingTimeMinutes: averageProcessingTimeMinutes,
        centreDelayBufferMinutes: centreDelayBufferMinutes,
        status: QueueStatus.bookingConfirmed,
      ),
      statusHistory: [
        BookingStatusEvent(
          status: BookingStatus.confirmed,
          timestamp: DateTime.now(),
        ),
      ],
      procurement: ProcurementState(
        marketReferenceModalPricePerQtl: marketReferenceModalPricePerQtl,
        procurementRatePerQtl:
            procurementRatePerQtl ?? _demoProcurementRateForCrop(crop),
      ),
    );

    return repository.updateBooking(booking);
  }

  static double _demoProcurementRateForCrop(String crop) {
    switch (crop) {
      case 'Paddy':
        return 2200;
      case 'Wheat':
        return 2350;
      case 'Maize':
        return 1900;
      case 'Soybean':
        return 4200;
      case 'Gram':
        return 5800;
      default:
        return 2000;
    }
  }
}
