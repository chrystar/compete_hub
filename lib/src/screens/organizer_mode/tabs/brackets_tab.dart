import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../models/match.dart';
import '../../../providers/event_provider.dart';
import 'package:provider/provider.dart';

class BracketsTab extends StatelessWidget {
  final Event event;

  const BracketsTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBracketControls(context),
        Expanded(child: _buildBracketView(context)),
      ],
    );
  }

  Widget _buildBracketControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _generateBrackets(context),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Brackets'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showScheduleDialog(context),
            icon: const Icon(Icons.schedule),
            label: const Text('Schedule Matches'),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketView(BuildContext context) {
    return StreamBuilder<List<Match>?>(
      // Make the type parameter nullable
      stream: Provider.of<EventProvider>(context).getEventMatches(event.id),
      builder: (context, AsyncSnapshot<List<Match>?> snapshot) {
        // Explicitly type the snapshot
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matches = snapshot.data ?? []; // Provide default empty list
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                    'Round ${match.round}: ${match.player1} vs ${match.player2}'),
                subtitle:
                    Text(match.scheduledTime?.toString() ?? 'Not scheduled'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showMatchDetailsDialog(context, match),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _generateBrackets(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Brackets'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will create a new tournament bracket.'),
            const Text('Existing brackets will be cleared.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<EventProvider>(context, listen: false)
                    .generateBrackets(event.id);
                Navigator.pop(context);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    // Implementation for match scheduling
  }

  void _showMatchDetailsDialog(BuildContext context, Match match) {
    // Implementation for match details/editing
  }
}
