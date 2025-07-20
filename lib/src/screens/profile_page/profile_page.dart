import 'package:compete_hub/providers/auth_provider.dart';
import 'package:compete_hub/src/providers/event_provider.dart';
import 'package:compete_hub/src/screens/organizer_mode/organizer_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/event_creation/event_creation.dart';
import 'package:compete_hub/src/auth/sign_in.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
      body: Consumer<AuthProviders>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view profile',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: colorScheme.surface,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            child: Text(
                              user.email?[0].toUpperCase() ?? '?',
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 36,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? 'User',
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? 'No email',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
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
                                colorScheme,
                                textTheme,
                              );
                            },
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: colorScheme.outline,
                          ),
                          StreamBuilder<int>(
                            stream: Provider.of<EventProvider>(context)
                                .getUserRegistrationsCount(user.uid),
                            builder: (context, snapshot) {
                              return _buildStatItem(
                                'Registered',
                                snapshot.data?.toString() ?? '0',
                                colorScheme,
                                textTheme,
                              );
                            },
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: colorScheme.outline,
                          ),
                          _buildStatItem('Wins', '0', colorScheme, textTheme),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Create Event',
                        subtitle: 'Organize a new competition',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventCreation(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Organizer Mode',
                        subtitle: 'Manage your events',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrganizerModeScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        subtitle: 'Sign out of your account',
                        onTap: () async {
                          await authProvider.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Tabs Section
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: colorScheme.primary,
                        labelColor: colorScheme.primary,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        labelStyle: textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'My Events'),
                          Tab(text: 'Registered'),
                          Tab(text: 'Settings'),
                        ],
                      ),
                      SizedBox(
                        height: 400,
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? colorScheme.error.withOpacity(0.1)
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive 
                        ? colorScheme.error
                        : colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMyEventsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection('My Created Events', Icons.event_outlined),
          const SizedBox(height: 8),
          _buildProfileSection('Event Analytics', Icons.analytics_outlined),
        ],
      ),
    );
  }

  Widget _buildRegisteredEventsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection('Registered Events', Icons.how_to_reg_outlined),
          const SizedBox(height: 8),
          _buildProfileSection('Competition History', Icons.history_outlined),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection('Account Settings', Icons.settings_outlined),
          const SizedBox(height: 8),
          _buildProfileSection('Notifications', Icons.notifications_outlined),
          const SizedBox(height: 8),
          _buildProfileSection('Privacy & Security', Icons.security_outlined),
          const SizedBox(height: 8),
          _buildProfileSection('Help & Support', Icons.help_outline),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (title == 'My Created Events') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrganizerModeScreen(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
