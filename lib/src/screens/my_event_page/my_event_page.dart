import 'package:compete_hub/src/models/announcement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';
import '../../../core/utils/app_colors.dart';

class MyEventPage extends StatefulWidget {
  const MyEventPage({super.key});

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text('My Events', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface, fontSize: 24)),
        actions: [
          _buildNotificationBadge(context, colorScheme),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(colorScheme, textTheme),
          _buildNotificationsTab(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context, ColorScheme colorScheme) {
    return StreamBuilder<List<Announcement>>(
      stream: Provider.of<EventProvider>(context).getMyNotifications(),
      builder: (context, snapshot) {
        final hasUnread =
            snapshot.hasData && snapshot.data!.any((n) => !n.isRead);
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: colorScheme.onPrimary),
              onPressed: () => _tabController.animateTo(1),
            ),
            if (hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEventsTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<String>>(
          stream: provider.streamRegisteredEventIds(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error:  ${snapshot.error}',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final registeredEventIds = snapshot.data ?? [];

            if (registeredEventIds.isEmpty) {
              return Center(
                child: Text(
                  'You haven\'t registered for any events yet',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                ),
              );
            }

            return StreamBuilder<List<Event>>(
              stream: provider.streamEvents(),
              builder: (context, eventsSnapshot) {
                if (!eventsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allEvents = eventsSnapshot.data!;
                final registeredEvents = allEvents
                    .where((event) => registeredEventIds.contains(event.id))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: registeredEvents.length,
                  itemBuilder: (context, index) {
                    final event = registeredEvents[index];
                    return Card(
                      color: colorScheme.surface,
                      child: EventCard(
                        event: event,
                        onRegister: () {},
                        isRegistered: true,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Announcement>>(
          stream: provider.getMyNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  'No notifications yet',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: notification.isRead
                      ? colorScheme.surfaceVariant
                      : colorScheme.secondary.withOpacity(0.2),
                  child: ListTile(
                    title: Text(
                      notification.message,
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      _formatDateTime(notification.timestamp),
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    onTap: () => provider.markNotificationRead(notification.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
