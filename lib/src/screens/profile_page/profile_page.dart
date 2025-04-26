import 'package:compete_hub/providers/auth_provider.dart';
import 'package:compete_hub/src/providers/event_provider.dart';
import 'package:compete_hub/src/screens/organizer_mode/organizer_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/event_creation/event_creation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Consumer<AuthProviders>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Please login to view profile'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        user.email?[0].toUpperCase() ?? '?',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StreamBuilder<int>(
                          stream: Provider.of<EventProvider>(context)
                              .getUserEventsCount(user.uid),
                          builder: (context, snapshot) {
                            return _buildStatItem(
                              'Events',
                              snapshot.data?.toString() ?? '0',
                            );
                          },
                        ),
                        StreamBuilder<int>(
                          stream: Provider.of<EventProvider>(context)
                              .getUserRegistrationsCount(user.uid),
                          builder: (context, snapshot) {
                            return _buildStatItem(
                              'Registered',
                              snapshot.data?.toString() ?? '0',
                            );
                          },
                        ),
                        _buildStatItem('Wins', '0'), // To be implemented later
                      ],
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(text: 'My Events'),
                  Tab(text: 'Registered'),
                  Tab(text: 'Settings'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyEventsTab(),
                    _buildRegisteredEventsTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventCreation()),
          );
        },
        backgroundColor: Colors.deepPurple,
        label: const Text('Create Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMyEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileSection('My Events'),
      ],
    );
  }

  Widget _buildRegisteredEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileSection('Registered Events'),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileSection('Settings'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () =>
              Provider.of<AuthProviders>(context, listen: false).signOut(),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _buildProfileSection(String title) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),
        onTap: () {
          if (title == 'My Events') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrganizerModeScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
