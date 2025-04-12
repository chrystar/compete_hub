import 'package:compete_hub/src/models/registration.dart';
import 'package:compete_hub/src/screens/organizer_mode/screens/news_post_screen.dart';
import 'package:compete_hub/src/screens/payment_management/payment_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import 'tabs/participants_tab.dart';

class EventManagementScreen extends StatefulWidget {
  final Event event;

  const EventManagementScreen({super.key, required this.event});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: Text(widget.event.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildDashboardCard(
                  context,
                  'Participants',
                  Icons.people,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParticipantsTab(event: widget.event),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Payments',
                  Icons.payment,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentManagementScreen(event: widget.event),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Brackets',
                  Icons.category,
                  Colors.orange,
                  () {}, // Add bracket management navigation
                ),
                _buildDashboardCard(
                  context,
                  'Announcements',
                  Icons.campaign,
                  Colors.purple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsPostScreen(event: widget.event),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Live Chat',
                  Icons.chat,
                  Colors.red,
                  () {}, // Add live chat navigation
                ),
                _buildDashboardCard(
                  context,
                  'Results',
                  Icons.emoji_events,
                  Colors.amber,
                  () {}, // Add results management navigation
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return StreamBuilder<List<Registration>>(
      stream:
          Provider.of<EventProvider>(context).getEventRegistrations(widget.event.id),
      builder: (context, snapshot) {
        final totalRegistrations = snapshot.data?.length ?? 0;
        final approvedRegistrations = snapshot.data
                ?.where((r) => r.paymentStatus == PaymentStatus.approved)
                .length ??
            0;
        final pendingRegistrations = snapshot.data
                ?.where((r) => r.paymentStatus == PaymentStatus.pending)
                .length ??
            0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Total', totalRegistrations, Colors.blue),
            _buildStatCard('Approved', approvedRegistrations, Colors.green),
            _buildStatCard('Pending', pendingRegistrations, Colors.orange),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      color: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
