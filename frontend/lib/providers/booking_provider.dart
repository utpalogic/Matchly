import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _bookings = [];
  Booking? _selectedBooking;

  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get upcoming bookings
  List<Booking> get upcomingBookings {
    return _bookings.where((b) => b.isUpcoming).toList();
  }

  // Get past bookings
  List<Booking> get pastBookings {
    return _bookings.where((b) => b.isPast).toList();
  }

  // Get cancelled bookings
  List<Booking> get cancelledBookings {
    return _bookings.where((b) => b.status == 'CANCELLED').toList();
  }

  // Fetch user's bookings
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.bookings);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        _bookings = data.map((json) => Booking.fromJson(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Create booking
  Future<bool> createBooking({
    required int timeSlotId,
    int? teamId,
    required double amount,
    String? khaltiToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConstants.bookings,
        data: {
          'time_slot': timeSlotId,
          'team': teamId,
          'amount_paid': amount,
          'khalti_token': khaltiToken,
          'payment_status': khaltiToken != null ? 'PAID' : 'PENDING',
        },
      );

      _isLoading = false;

      if (response.statusCode == 201) {
        // Refresh bookings list
        await fetchBookings();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to create booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final endpoint = ApiConstants.cancelBooking.replaceAll(
        '{id}',
        bookingId.toString(),
      );
      final response = await _apiService.patch(endpoint);

      _isLoading = false;

      if (response.statusCode == 200) {
        // Refresh bookings list
        await fetchBookings();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to cancel booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get booking by ID
  Future<void> getBookingById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiConstants.bookings}$id/');

      if (response.statusCode == 200) {
        _selectedBooking = Booking.fromJson(response.data);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear selected booking
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
