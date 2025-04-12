import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../models/announcement.dart';
import '../../../providers/event_provider.dart';
import 'package:provider/provider.dart';

class CommunicationsTab extends StatefulWidget {
  final Event event;

  const CommunicationsTab({super.key, required this.event});

  @override
  State<CommunicationsTab> createState() => _CommunicationsTabState();
}

class _CommunicationsTabState extends State<CommunicationsTab> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAnnouncementInput(),
        const Divider(),
        Expanded(child: _buildAnnouncementsList()),
      ],
    );
  }

  Widget _buildAnnouncementInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Type your announcement...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _sendAnnouncement,
                icon: const Icon(Icons.send),
                label: const Text('Send to All'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showTemplateDialog(),
                icon: const Icon(Icons.insert_drive_file_outlined),
                label: const Text('Templates'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    return StreamBuilder<List<Announcement>>(
      stream:
          Provider.of<EventProvider>(context).getAnnouncements(widget.event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final announcements = snapshot.data!;
        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: ListTile(
                title: Text(announcement.message),
                subtitle: Text(
                  _formatDateTime(announcement.timestamp),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) => _handleAnnouncementAction(
                    value,
                    announcement,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _sendAnnouncement() async {
    if (_messageController.text.isEmpty) return;

    try {
      await Provider.of<EventProvider>(context, listen: false)
          .createAnnouncement(
        widget.event.id,
        _messageController.text,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showTemplateDialog() {
    // Show template selection dialog
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _handleAnnouncementAction(String action, Announcement announcement) {
    // Handle edit/delete actions
  }
}
