import 'package:flutter/foundation.dart';
import 'package:frontend/services/auth_services.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Check if user is owner
  bool get isOwner => _currentUser?.role == 'OWNER';

  // Check if user is admin
  bool get isAdmin => _currentUser?.role == 'ADMIN';

  // Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? preferredPosition,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        preferredPosition: preferredPosition,
      );

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Load current user on app start
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? preferredPosition,
    bool? isLookingForTeam,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        phone: phone,
        fullName: fullName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        preferredPosition: preferredPosition,
        isLookingForTeam: isLookingForTeam,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
