import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    String? preferredPosition,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'preferred_position': preferredPosition,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful! Please login.',
        };
      }

      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Save tokens
        await _storageService.saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );

        // Save user data
        final user = User.fromJson(data['user']);
        await _storageService.saveUserData(
          userId: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
        );

        return {'success': true, 'message': 'Login successful!', 'user': user};
      }

      return {'success': false, 'message': 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) return null;

      final response = await _apiService.get('${ApiConstants.users}$userId/');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? phone,
    String? preferredPosition,
    bool? isLookingForTeam,
  }) async {
    try {
      final userId = await _storageService.getUserId();
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final response = await _apiService.patch(
        '${ApiConstants.users}$userId/',
        data: {
          if (phone != null) 'phone': phone,
          if (preferredPosition != null)
            'preferred_position': preferredPosition,
          if (isLookingForTeam != null) 'is_looking_for_team': isLookingForTeam,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully!',
          'user': User.fromJson(response.data),
        };
      }

      return {'success': false, 'message': 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully!'};
      }

      return {'success': false, 'message': 'Failed to change password'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
