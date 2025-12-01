import 'package:flutter/foundation.dart';
import '../models/futsal_model.dart';
import '../services/api_service.dart';
import '../core/constants/api_constants.dart';

class FutsalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Futsal> _futsals = [];
  Futsal? _selectedFutsal;
  List<Ground> _grounds = [];
  List<TimeSlot> _timeSlots = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Futsal> get futsals => _futsals;
  Futsal? get selectedFutsal => _selectedFutsal;
  List<Ground> get grounds => _grounds;
  List<TimeSlot> get timeSlots => _timeSlots;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all futsals
  Future<void> fetchFutsals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConstants.futsals);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        _futsals = data.map((json) => Futsal.fromJson(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get futsal by ID
  Future<void> getFutsalById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('${ApiConstants.futsals}$id/');

      if (response.statusCode == 200) {
        _selectedFutsal = Futsal.fromJson(response.data);

        // Also load grounds for this futsal
        if (response.data['grounds'] != null) {
          final List<dynamic> groundsData = response.data['grounds'];
          _grounds = groundsData.map((json) => Ground.fromJson(json)).toList();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Fetch time slots for a ground on a specific date
  Future<void> fetchTimeSlots({
    required int groundId,
    required String date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.timeSlots,
        queryParameters: {'ground': groundId, 'date': date},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        _timeSlots = data.map((json) => TimeSlot.fromJson(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Search futsals
  void searchFutsals(String query) {
    if (query.isEmpty) {
      notifyListeners();
      return;
    }

    _futsals = _futsals.where((futsal) {
      return futsal.name.toLowerCase().contains(query.toLowerCase()) ||
          futsal.location.toLowerCase().contains(query.toLowerCase());
    }).toList();

    notifyListeners();
  }

  // Clear selected futsal
  void clearSelectedFutsal() {
    _selectedFutsal = null;
    _grounds = [];
    _timeSlots = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
