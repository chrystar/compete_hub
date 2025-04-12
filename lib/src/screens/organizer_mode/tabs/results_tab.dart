import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../models/match.dart';
import '../../../providers/event_provider.dart';
import 'package:provider/provider.dart';

class ResultsTab extends StatefulWidget {
  final Event event;

  const ResultsTab({super.key, required this.event});

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showPublicResults = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildResultControls(),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Match Results'),
            Tab(text: 'Leaderboard'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMatchResults(),
              _buildLeaderboard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SwitchListTile(
            title: const Text('Public Results'),
            value: _showPublicResults,
            onChanged: (value) => setState(() => _showPublicResults = value),
          ),
          ElevatedButton.icon(
            onPressed: () => _exportResults(),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResults() {
    return StreamBuilder<List<Match>>(
      stream:
          Provider.of<EventProvider>(context).getEventMatches(widget.event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matches = snapshot.data!;
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              child: ListTile(
                title: Text('${match.player1} vs ${match.player2}'),
                subtitle: Text(match.scores?.toString() ?? 'No results'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showScoreDialog(match),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream:
          Provider.of<EventProvider>(context).getLeaderboard(widget.event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final standings = snapshot.data!;
        return ListView.builder(
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final player = standings[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(player['name']),
              trailing: Text('${player['points']} pts'),
            );
          },
        );
      },
    );
  }

  void _showScoreDialog(Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Score'),
        content: _ScoreInputForm(match: match),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save scores
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportResults() {
    // Implementation for exporting results
  }
}

class _ScoreInputForm extends StatefulWidget {
  final Match match;

  const _ScoreInputForm({required this.match});

  @override
  State<_ScoreInputForm> createState() => _ScoreInputFormState();
}

class _ScoreInputFormState extends State<_ScoreInputForm> {
  final _player1ScoreController = TextEditingController();
  final _player2ScoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _player1ScoreController,
          decoration: InputDecoration(
            labelText: widget.match.player1,
          ),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _player2ScoreController,
          decoration: InputDecoration(
            labelText: widget.match.player2,
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
