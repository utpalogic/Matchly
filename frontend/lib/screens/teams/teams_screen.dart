import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/team_model.dart';
import '../../services/api_service.dart';
import 'create_team_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({Key? key}) : super(key: key);

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<Team> _allTeams = [];
  List<Team> _myTeams = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserAndTeams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAndTeams() async {
    setState(() => _isLoading = true);

    try {
      // Getting the current user
      final userResponse = await _apiService.get('/api/users/me/');
      _currentUserId = userResponse.data['id'];

      // Getting all teams
      final allResponse = await _apiService.get('/api/teams/');

      // Getting my teams
      final myResponse = await _apiService.get('/api/teams/my-teams/');

      // Extracting teams lists
      var allTeamsList = allResponse.data['results'];
      var myTeamsList = myResponse.data;

      // Converting to Team objects
      setState(() {
        _allTeams = [];
        _myTeams = [];

        // Parseing all teams
        for (var teamJson in allTeamsList) {
          try {
            _allTeams.add(Team.fromJson(teamJson));
          } catch (e) {
            print('Error parsing team: $e');
          }
        }

        // Parsing my teams
        for (var teamJson in myTeamsList) {
          try {
            _myTeams.add(Team.fromJson(teamJson));
          } catch (e) {
            print('Error parsing my team: $e');
          }
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading teams'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isMyTeam(Team team) {
    return _myTeams.any((t) => t.id == team.id);
  }

  bool _isCaptain(Team team) {
    return _currentUserId != null && team.captain == _currentUserId;
  }

  Future<void> _joinTeam(Team team) async {
    try {
      final response = await _apiService.post('/api/teams/${team.id}/join/');

      if (response.statusCode == 200) {
        _fetchUserAndTeams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'] ?? 'Joined team successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _leaveTeam(Team team) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team'),
        content: Text('Are you sure you want to leave ${team.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _apiService.post('/api/teams/${team.id}/leave/');

      if (response.statusCode == 200) {
        _fetchUserAndTeams(); // Refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['message'] ?? 'Left team successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('Captain cannot leave')
            ? 'Captain cannot leave team'
            : 'Error: $e';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteTeam(Team team) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete "${team.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _apiService.delete('/api/teams/${team.id}/');

      if (response.statusCode == 204 || response.statusCode == 200) {
        _fetchUserAndTeams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Team deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting team: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Teams'),
            Tab(text: 'My Teams'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [_buildAllTeamsTab(), _buildMyTeamsTab()],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          print('Step 1: Opening Create Team screen');

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
          );

          print('Step 2: Back from Create Team. Result = $result');

          if (result == true) {
            print('Step 3: Result is true, calling _fetchUserAndTeams()');
            await _fetchUserAndTeams();
            print('Step 4: Fetch completed!');
          } else {
            print('Result was $result, NOT refreshing');
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAllTeamsTab() {
    if (_allTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No teams available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserAndTeams,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allTeams.length,
        itemBuilder: (context, index) {
          final team = _allTeams[index];
          final isMyTeam = _isMyTeam(team);

          // adding debug print
          print(
            'Team: ${team.name}, isMyTeam: $isMyTeam, showJoin: ${!isMyTeam}',
          );
          return _buildTeamCard(team, showJoinButton: !isMyTeam);
        },
      ),
    );
  }

  Widget _buildMyTeamsTab() {
    if (_myTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'You haven\'t joined any teams yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Browse Teams',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUserAndTeams,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myTeams.length,
        itemBuilder: (context, index) {
          final team = _myTeams[index];
          return _buildTeamCard(
            team,
            showJoinButton: false,
            showLeaveButton: true,
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(
    Team team, {
    required bool showJoinButton,
    bool showLeaveButton = false,
  }) {
    final isCaptain = _isCaptain(team);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Team Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.groups, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              // Team Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCaptain)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Captain',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Captain: ${team.captainName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _buildStatChip(
                Icons.people,
                '${team.memberCount} members',
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                Icons.sports_soccer,
                '${team.matchesCount} matches',
                Colors.green,
              ),
            ],
          ),
          // join button
          if (showJoinButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinTeam(team),
                icon: const Icon(
                  Icons.group_add,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Join Team',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // leave or delete button
          if (showLeaveButton) ...[
            const SizedBox(height: 16),

            // Member leave button
            if (!isCaptain)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _leaveTeam(team),
                  icon: const Icon(Icons.exit_to_app, size: 20),
                  label: const Text(
                    'Leave Team',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Captain delete button
            if (isCaptain)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _deleteTeam(team),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.white),
                  label: const Text(
                    'Delete Team',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
