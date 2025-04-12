import 'package:compete_hub/src/models/registration.dart';
import 'package:compete_hub/src/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onRegister;
  final bool isRegistered;

  const EventCard({
    Key? key,
    required this.event,
    this.onRegister,
    this.isRegistered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRegistered
          ? Colors.green.withOpacity(0.2)
          : Colors.white.withOpacity(0.1),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      event.locationType == EventLocationType.online
                          ? Icons.computer
                          : Icons.location_on,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.location ?? 'Online',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Format: ${event.format.toString().split('.').last}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (!isRegistered)
                      ElevatedButton(
                        onPressed: onRegister,
                        child: const Text('Register'),
                      )
                    else
                      const Chip(
                        label: Text('Registered'),
                        backgroundColor: Colors.green,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: StreamBuilder<List<Registration>>(
              stream: Provider.of<EventProvider>(context)
                  .getEventRegistrations(event.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }

                // Remove duplicates and get unique registrations
                final registrations = snapshot.data!;
                final uniqueRegistrations = registrations.toSet().toList();
                final displayCount = uniqueRegistrations.length.clamp(0, 3);
                final hasMore = uniqueRegistrations.length > 3;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasMore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${uniqueRegistrations.length - 3}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    ...uniqueRegistrations
                        .take(displayCount)
                        .map((reg) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: UserAvatar(
                              name: reg.fullName[0],
                              size: 30,
                              color: Colors.deepPurple.shade300,
                            ),
                          );
                        })
                        .toList()
                        .reversed,
                  ],
                );
              },
            ),
          ),
          if (isRegistered)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Registered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
