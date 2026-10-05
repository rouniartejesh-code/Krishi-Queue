import '../../booking/domain/booking.dart';

abstract class ProcurementRepository {
  Future<Booking> getBooking();

  Future<Booking> advanceProcurement(
    Booking booking,
  );
}