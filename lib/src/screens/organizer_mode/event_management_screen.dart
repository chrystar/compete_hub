import 'package:compete_hub/src/models/registration.dart';
import 'package:compete_hub/src/screens/organizer_mode/screens/news_post_screen.dart';
import 'package:compete_hub/src/screens/organizer_mode/screens/participants_dashboard.dart';
import 'package:compete_hub/src/screens/payment_management/payment_management_screen.dart';
import 'package:compete_hub/src/screens/feedback/event_feedback_screen.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.event.name,
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Dashboard',
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildStatsRow(context, colorScheme, textTheme),
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
                  colorScheme.secondary,
                  colorScheme.onSecondary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ParticipantsDashboard(event: widget.event),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Payments',
                  Icons.payment,
                  widget.event.feeType == EventFeeType.free
                      ? colorScheme.surfaceVariant
                      : colorScheme.tertiary ?? colorScheme.secondary,
                  colorScheme.onSurface,
                  widget.event.feeType == EventFeeType.free
                      ? null
                      : () => Navigator.push(
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
                  colorScheme.primaryContainer,
                  colorScheme.onPrimaryContainer,
                  () {},
                ),
                _buildDashboardCard(
                  context,
                  'Announcements',
                  Icons.campaign,
                  colorScheme.secondaryContainer,
                  colorScheme.onSecondaryContainer,
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
                  colorScheme.error,
                  colorScheme.onError,
                  () {},
                ),
                _buildDashboardCard(
                  context,
                  'Feedback',
                  Icons.feedback,
                  colorScheme.primary,
                  colorScheme.onPrimary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventFeedbackScreen(
                        event: widget.event,
                        canSubmitFeedback: false,
                      ),
                    ),
                  ),
                ),
                _buildDashboardCard(
                  context,
                  'Results',
                  Icons.emoji_events,
                  colorScheme.secondary,
                  colorScheme.onSecondary,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return StreamBuilder<List<Registration>>(
      stream: Provider.of<EventProvider>(context)
          .getEventRegistrations(widget.event.id),
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
            _buildStatCard('Total', totalRegistrations, colorScheme.secondary, colorScheme.onSecondary, textTheme),
            _buildStatCard('Approved', approvedRegistrations, colorScheme.tertiary ?? colorScheme.secondary, colorScheme.onTertiary ?? colorScheme.onSecondary, textTheme),
            _buildStatCard('Pending', pendingRegistrations, colorScheme.error, colorScheme.onError, textTheme),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, int value, Color color, Color onColor, TextTheme textTheme) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: textTheme.headlineSmall?.copyWith(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(color: onColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, Color onColor, VoidCallback? onTap) {
    final textTheme = Theme.of(context).textTheme;
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
                style: textTheme.titleMedium?.copyWith(
                  color: onColor,
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
