class ApiConstants {
  // Base URL - Change this to your backend IP when running on device
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Auth endpoints
  static const String login = '/api/token/';
  static const String refreshToken = '/api/token/refresh/';
  static const String register = '/api/register/';
  static const String changePassword = '/api/change-password/';

  // User endpoints
  static const String users = '/api/users/';
  static const String userMe = '/api/users/me/';

  // Futsal endpoints
  static const String futsals = '/api/futsals/';
  static const String grounds = '/api/grounds/';
  static const String timeSlots = '/api/time-slots/';

  // Booking endpoints
  static const String bookings = '/api/bookings/';
  static const String cancelBooking = '/api/bookings/{id}/cancel/';

  // Team endpoints
  static const String teams = '/api/teams/';
  static const String joinTeam = '/api/teams/{id}/join/';
  static const String leaveTeam = '/api/teams/{id}/leave/';

  // Community endpoints
  static const String posts = '/api/posts/';
  static const String likePost = '/api/posts/{id}/like/';
  static const String commentPost = '/api/posts/{id}/comment/';

  // Tournament endpoints
  static const String tournaments = '/api/tournaments/';
  static const String registerTournament = '/api/tournaments/{id}/register/';
  static const String fixtures = '/api/fixtures/';

  // Payment endpoints
  static const String verifyPayment = '/api/verify-khalti-payment/';

  // Utility function to replace {id} in URLs
  static String replaceId(String endpoint, dynamic id) {
    return endpoint.replaceAll('{id}', id.toString());
  }
}
