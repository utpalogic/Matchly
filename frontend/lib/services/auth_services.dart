import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService apiService = ApiService();
  final StorageService storageService = StorageService();

  // Register new user
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
    try {
      final response = await apiService.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'phone': phone,
          'full_name': fullName,
          'gender': gender,
          'date_of_birth': dateOfBirth,
          'preferred_position': preferredPosition,
        },
      );

      return {
        'success': true,
        'message': response.data['message'],
        'user': User.fromJson(response.data['user']),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await apiService.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      // Save tokens
      await storageService.saveTokens(
        accessToken: response.data['access'],
        refreshToken: response.data['refresh'],
      );

      // Get user info
      final userResponse = await apiService.get(ApiConstants.userMe);
      final user = User.fromJson(userResponse.data);

      // Save user info
      await storageService.saveUserId(user.id);
      await storageService.saveUsername(user.username);
      await storageService.saveRole(user.role);

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': _extractErrorMessage(e)};
    }
  }

  // Added new method to extract error messages
  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('No active account found')) {
      return 'Invalid username or password';
    }
    if (error.toString().contains('Connection')) {
      return 'Connection error. Check your internet.';
    }
    if (error.toString().contains('401')) {
      return 'Invalid username or password';
    }
    return 'Login failed. Please try again.';
  }

  // Logout
  Future<void> logout() async {
    await storageService.clearAll();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userId = await storageService.getUserId();
      if (userId == null) return null;

      final response = await apiService.get('${ApiConstants.users}$userId/');
      return User.fromJson(response.data);
    } catch (e) {
      return null;
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
    try {
      final response = await apiService.patch(
        ApiConstants.updateProfile,
        data: {
          if (phone != null) 'phone': phone,
          if (fullName != null) 'full_name': fullName,
          if (gender != null) 'gender': gender,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (preferredPosition != null)
            'preferred_position': preferredPosition,
          if (isLookingForTeam != null) 'is_looking_for_team': isLookingForTeam,
        },
      );

      return {'success': true, 'user': User.fromJson(response.data)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await apiService.post(
        ApiConstants.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Forgot Password - Send reset token
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await apiService.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return {
        'success': true,
        'message': response.data['message'],
        'token': response.data['token'], // For testing only
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reset Password - Use token to set new password
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await apiService.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      );
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
