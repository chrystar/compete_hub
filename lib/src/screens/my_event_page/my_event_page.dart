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
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('My Events'),
        actions: [
          _buildNotificationBadge(context),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: Provider.of<EventProvider>(context).getMyNotifications(),
      builder: (context, snapshot) {
        final hasUnread =
            snapshot.hasData && snapshot.data!.any((n) => !n.isRead);
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _tabController.animateTo(1),
            ),
            if (hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
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

  Widget _buildEventsTab() {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<String>>(
          stream: provider.streamRegisteredEventIds(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final registeredEventIds = snapshot.data ?? [];

            if (registeredEventIds.isEmpty) {
              return const Center(
                child: Text(
                  'You haven\'t registered for any events yet',
                  style: TextStyle(color: Colors.white),
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
                    return EventCard(
                      event: event,
                      onRegister: () {},
                      isRegistered: true,
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

  Widget _buildNotificationsTab() {
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
              return const Center(
                child: Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  color: notification.isRead
                      ? Colors.black12
                      : Colors.deepPurple.withOpacity(0.2),
                  child: ListTile(
                    title: Text(
                      notification.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _formatDateTime(notification.timestamp),
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
