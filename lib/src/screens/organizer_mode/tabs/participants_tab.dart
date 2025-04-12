import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event.dart';
import '../../../models/participant.dart';
import '../../../providers/event_provider.dart';

class ParticipantsTab extends StatelessWidget {
  final Event event;

  const ParticipantsTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildParticipantActions(context),
          Expanded(child: _buildParticipantList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParticipantDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildParticipantActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showMessageDialog(context),
            icon: const Icon(Icons.message),
            label: const Text('Message All'),
          ),
          ElevatedButton.icon(
            onPressed: () => _exportParticipantList(context),
            icon: const Icon(Icons.download),
            label: const Text('Export List'),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantList(BuildContext context) {
    return StreamBuilder<List<Participant>>(
      stream: Provider.of<EventProvider>(context).getParticipants(event.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final participants = snapshot.data!;
        return ListView.builder(
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(participant.name[0].toUpperCase()),
              ),
              title: Text(participant.name),
              subtitle: Text(participant.email),
              trailing: _buildStatusDropdown(context, participant),
              onTap: () => _showParticipantDetails(context, participant),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context, Participant participant) {
    return DropdownButton<ParticipantStatus>(
      value: participant.status,
      items: ParticipantStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.toString().split('.').last),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          Provider.of<EventProvider>(context, listen: false)
              .updateParticipantStatus(participant.id, newStatus);
        }
      },
    );
  }

  void _showAddParticipantDialog(BuildContext context) {
    // Show dialog to manually add participant
    // Implementation to be added
  }

  void _showMessageDialog(BuildContext context) {
    // Show dialog to send mass message
    // Implementation to be added
  }

  void _exportParticipantList(BuildContext context) {
    // Export participant list functionality
    // Implementation to be added
  }

  void _showParticipantDetails(BuildContext context, Participant participant) {
    // Show detailed participant information
    // Implementation to be added
  }
}
