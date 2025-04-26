import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event.dart';
import '../../../models/registration.dart';
import '../../../providers/event_provider.dart';
import '../../../../core/utils/app_colors.dart';

class ParticipantsDashboard extends StatefulWidget {
  final Event event;

  const ParticipantsDashboard({super.key, required this.event});

  @override
  State<ParticipantsDashboard> createState() => _ParticipantsDashboardState();
}

class _ParticipantsDashboardState extends State<ParticipantsDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: Text(widget.event.feeType == EventFeeType.paid
            ? 'Approved Participants'
            : 'All Participants'),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<List<Registration>>(
              stream: widget.event.feeType == EventFeeType.free
                  ? Provider.of<EventProvider>(context)
                      .getEventRegistrations(widget.event.id)
                  : Provider.of<EventProvider>(context)
                      .getApprovedPaidRegistrations(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final registrations = snapshot.data ?? [];
                final filteredRegistrations = registrations
                    .where((reg) =>
                        reg.fullName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        reg.email
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredRegistrations.isEmpty) {
                  return const Center(
                    child: Text(
                      'No participants found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRegistrations.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final registration = filteredRegistrations[index];
                    return _buildParticipantCard(registration);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search participants...',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple.shade300),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildParticipantCard(Registration registration) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Text(registration.fullName),
        subtitle: Text(registration.email),
        trailing: _buildStatusChip(registration.paymentStatus),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', registration.phone),
                _buildInfoRow('Gender', registration.gender),
                _buildInfoRow('Location', registration.location),
                _buildInfoRow('Registration Date',
                    registration.registrationDate.toString()),
                if (registration.paymentStatus == PaymentStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text('Approve'),
                        onPressed: () => _updateStatus(
                            registration.id, PaymentStatus.approved),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Reject'),
                        onPressed: () => _updateStatus(
                            registration.id, PaymentStatus.rejected),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status) {
    final colors = {
      PaymentStatus.pending: Colors.orange,
      PaymentStatus.approved: Colors.green,
      PaymentStatus.rejected: Colors.red,
    };

    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: colors[status],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      String registrationId, PaymentStatus newStatus) async {
    try {
      await Provider.of<EventProvider>(context, listen: false)
          .updateRegistrationStatus(registrationId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status updated to ${newStatus.toString().split('.').last}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
