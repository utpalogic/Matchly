import 'package:flutter/material.dart';
import '../models/futsal_model.dart';
import '../services/api_service.dart';

class FutsalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Futsal> _futsals = [];
  List<Futsal> _filteredFutsals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Futsal> get futsals => _filteredFutsals.isEmpty && _searchQuery.isEmpty
      ? _futsals
      : _filteredFutsals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';

  Future<void> fetchFutsals() async {
    print('fetchFutsals called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/futsals/');
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both paginated and non-paginated responses
        final List<dynamic> results = data['results'] ?? data;

        _futsals = results.map((json) => Futsal.fromJson(json)).toList();
        _filteredFutsals = _futsals;

        print('Data count: ${results.length}');
        print('Futsals loaded: ${_futsals.length}');

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to load futsals';
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      print('Exception in fetchFutsals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchFutsals(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredFutsals = _futsals;
    } else {
      _filteredFutsals = _futsals.where((futsal) {
        final nameLower = futsal.name.toLowerCase();
        final locationLower = futsal.location?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            locationLower.contains(searchLower);
      }).toList();
    }

    notifyListeners();
  }

  Future<Futsal?> getFutsalById(int id) async {
    try {
      final response = await _apiService.get('/api/futsals/$id/');

      if (response.statusCode == 200) {
        return Futsal.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching futsal details: $e');
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
