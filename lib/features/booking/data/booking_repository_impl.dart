import '../domain/booking.dart';
import '../domain/booking_engine.dart';
import '../domain/booking_repository.dart';
import '../domain/booking_validator.dart';

class BookingRepositoryImpl implements BookingRepository {
  Booking _booking;

  BookingRepositoryImpl(Booking initialBooking)
      : _booking = initialBooking {
    BookingValidator.validate(initialBooking);
  }

  @override
  Future<Booking> getBooking() async {
    return _booking;
  }

  @override
  Future<Booking> updateBooking(Booking booking) async {
    BookingValidator.validate(booking);

    _booking = booking;

    return _booking;
  }

  @override
  Future<Booking> cancelBooking() async {
    final updatedBooking = BookingEngine.cancel(_booking);

    BookingValidator.validate(updatedBooking);

    _booking = updatedBooking;

    return _booking;
  }

  @override
  Future<Booking> completeBooking() async {
    final updatedBooking = BookingEngine.complete(_booking);

    BookingValidator.validate(updatedBooking);

    _booking = updatedBooking;

    return _booking;
  }
}