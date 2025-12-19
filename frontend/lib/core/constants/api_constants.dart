class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:8000';
  static const String apiUrl = '$baseUrl/api';

  // Auth endpoints
  static const String login = '$apiUrl/token/';
  static const String refreshToken = '$apiUrl/token/refresh/';
  static const String register = '$apiUrl/register/';
  static const String forgotPassword = '$apiUrl/forgot-password/';
  static const String resetPassword = '$apiUrl/reset-password/';

  // User endpoints
  static const String users = '$apiUrl/users/';
  static const String userMe = '$apiUrl/users/me/';
  static const String updateProfile = '$apiUrl/users/update_profile/';
  static const String changePassword = '$apiUrl/users/change_password/';
  static const String toggleLookingForTeam =
      '$apiUrl/users/toggle_looking_for_team/';
  static const String lookingForTeam = '$apiUrl/users/looking_for_team/';

  // Futsal endpoints
  static const String futsals = '$apiUrl/futsals/';
  static const String grounds = '$apiUrl/grounds/';
  static const String timeSlots = '$apiUrl/timeslots/';

  // Booking endpoints
  static const String bookings = '$apiUrl/bookings/';
  static const String cancelBooking = '$apiUrl/bookings/{id}/cancel/';
  static const String completeBooking = '$apiUrl/bookings/{id}/complete/';

  // Team endpoints
  static const String teams = '$apiUrl/teams/';
  static const String myTeams = '$apiUrl/teams/my_teams/';
  static const String joinTeam = '$apiUrl/teams/{id}/join/';
  static const String leaveTeam = '$apiUrl/teams/{id}/leave/';

  // Post endpoints
  static const String posts = '$apiUrl/posts/';
  static const String likePost = '$apiUrl/posts/{id}/like/';
  static const String addComment = '$apiUrl/posts/{id}/add_comment/';

  // Tournament endpoints
  static const String tournaments = '$apiUrl/tournaments/';
  static const String registerTeamForTournament =
      '$apiUrl/tournaments/{id}/register_team/';

  // Payment verification
  static const String verifyPayment = '$apiUrl/verify-payment/';

  // Helper method to replace {id} with actual id
  static String replaceId(String endpoint, int id) {
    return endpoint.replaceAll('{id}', id.toString());
  }
}
