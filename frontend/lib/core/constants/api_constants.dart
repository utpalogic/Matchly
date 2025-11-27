/// API endpoint constants
class ApiConstants {
  // Base URL - Change based on your setup
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Use different URLs based on platform:
  // Android Emulator: 'http://10.0.2.2:8000/api'
  // iOS Simulator: 'http://localhost:8000/api'
  // Physical Device: 'http://YOUR_COMPUTER_IP:8000/api'

  // Auth endpoints
  static const String register = '/register/';
  static const String login = '/token/';
  static const String refreshToken = '/token/refresh/';

  // User endpoints
  static const String userProfile = '/users/me/';
  static const String updateProfile = '/users/update_profile/';
  static const String lookingForTeam = '/users/looking_for_team/';
  static const String toggleLookingForTeam = '/users/toggle_looking_for_team/';

  // Futsal endpoints
  static const String futsals = '/futsals/';
  static String futsalDetail(int id) => '/futsals/$id/';
  static String availableSlots(int futsalId, String date) =>
      '/futsals/$futsalId/available_slots/?date=$date';

  // Booking endpoints
  static const String bookings = '/bookings/';
  static String cancelBooking(int id) => '/bookings/$id/cancel/';

  // Team endpoints
  static const String teams = '/teams/';
  static const String myTeams = '/teams/my_teams/';
  static String joinTeam(int id) => '/teams/$id/join/';
  static String leaveTeam(int id) => '/teams/$id/leave/';

  // Tournament endpoints
  static const String tournaments = '/tournaments/';
  static String tournamentDetail(int id) => '/tournaments/$id/';
  static String tournamentFixtures(int id) => '/fixtures/?tournament=$id';

  // Community endpoints
  static const String posts = '/posts/';
  static String likePost(int id) => '/posts/$id/like/';
  static String addComment(int id) => '/posts/$id/add_comment/';
}
