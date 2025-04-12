import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../models/chat_message.dart';
import '../../../providers/event_provider.dart';
import 'package:provider/provider.dart';

class LiveTab extends StatefulWidget {
  final Event event;

  const LiveTab({super.key, required this.event});

  @override
  State<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends State<LiveTab> {
  final _messageController = TextEditingController();
  bool _isStreamActive = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStreamControls(),
        _buildLiveScoreUpdate(),
        Expanded(child: _buildLiveChat()),
      ],
    );
  }

  Widget _buildStreamControls() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Stream',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: _isStreamActive,
                  onChanged: (value) => setState(() => _isStreamActive = value),
                ),
                const SizedBox(width: 8),
                Text(_isStreamActive ? 'Stream Active' : 'Stream Inactive'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _configureStream(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Configure'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveScoreUpdate() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Update Score',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateLiveScore(),
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveChat() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: Provider.of<EventProvider>(context)
                  .getLiveChat(widget.event.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.senderName),
                      subtitle: Text(message.content),
                      trailing: Text(_formatTime(message.timestamp)),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _configureStream() {
    // Implement stream configuration
  }

  void _updateLiveScore() {
    // Implement live score update
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    // Implement message sending
    _messageController.clear();
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute}';
  }
}
