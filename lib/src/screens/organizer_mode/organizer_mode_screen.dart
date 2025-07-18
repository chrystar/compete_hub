import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';
import '../event_creation/event_creation.dart';
import 'event_management_screen.dart';

class OrganizerModeScreen extends StatelessWidget {
  const OrganizerModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text('My Events', style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EventCreation()),
            ),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          return StreamBuilder<List<Event>>(
            stream: provider.getUserEvents(provider.currentUserId),
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

              final events = snapshot.data ?? [];
              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No events created yet',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EventCreation(),
                          ),
                        ),
                        icon: Icon(Icons.add, color: colorScheme.primary),
                        label: Text('Create Event', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    color: colorScheme.surface,
                    child: ListTile(
                      title: Text(
                        event.name,
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        event.description,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventManagementScreen(event: event),
                        ),
                      ),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit', style: textTheme.bodyMedium),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: textTheme.bodyMedium),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Navigate to edit event
                          } else if (value == 'delete') {
                            await provider.deleteEvent(event.id);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
