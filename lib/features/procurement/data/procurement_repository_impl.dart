import '../../booking/domain/booking.dart';
import '../../booking/domain/booking_repository.dart';
import '../domain/procurement_engine.dart';
import '../domain/procurement_repository.dart';

class ProcurementRepositoryImpl
    implements ProcurementRepository {
  final BookingRepository _bookingRepository;

  ProcurementRepositoryImpl(
    this._bookingRepository,
  );

  @override
  Future<Booking> getBooking() {
    return _bookingRepository.getBooking();
  }

  @override
  Future<Booking> advanceProcurement(
    Booking booking,
  ) async {
    final updatedBooking =
        ProcurementEngine.advance(booking);

    return _bookingRepository.updateBooking(
      updatedBooking,
    );
  }
}