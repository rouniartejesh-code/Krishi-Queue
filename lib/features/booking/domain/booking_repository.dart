import 'booking.dart';

abstract class BookingRepository {
  Future<Booking> getBooking();

  Future<Booking> updateBooking(Booking booking);

  Future<Booking> cancelBooking();

  Future<Booking> completeBooking();
}
