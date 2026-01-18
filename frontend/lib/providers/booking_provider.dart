import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create a new booking
  Future<bool> createBooking({
    required int timeSlotId,
    required int groundId,
    required double amountPaid,
    int? teamId,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/api/bookings/',
        data: {
          'time_slot': timeSlotId,
          'ground': groundId,
          'amount_paid': amountPaid,
          'payment_status': 'PENDING',
          'status': 'CONFIRMED',
          if (teamId != null) 'team': teamId,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Booking created successfully!');
        _isLoading = false;
        notifyListeners();

        // Refresh bookings list
        await fetchMyBookings();

        return true;
      } else {
        _errorMessage = 'Failed to create booking';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error creating booking: $e');
      return false;
    }
  }

  // Fetch user's bookings
  Future<void> fetchMyBookings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.get('/api/bookings/');

      if (response.statusCode == 200) {
        // Check if response is paginated
        final data = response.data;

        if (data is Map && data.containsKey('results')) {
          // Paginated response
          _bookings = (data['results'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();
        } else if (data is List) {
          // Direct list response
          _bookings = data.map((json) => Booking.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format');
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.post(
        '/api/bookings/$bookingId/cancel/',
      );

      if (response.statusCode == 200) {
        await fetchMyBookings();
        return true;
      }
      return false;
    } catch (e) {
      print('Error canceling booking: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
