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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(widget.event.feeType == EventFeeType.paid
            ? 'Approved Participants'
            : 'All Participants', style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
      ),
      body: Column(
        children: [
          _buildSearchField(colorScheme, textTheme),
          Expanded(
            child: StreamBuilder<List<Registration>>(
              stream: widget.event.feeType == EventFeeType.free
                  ? Provider.of<EventProvider>(context)
                      .getEventRegistrations(widget.event.id)
                  : Provider.of<EventProvider>(context)
                      .getApprovedPaidRegistrations(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: textTheme.bodyLarge?.copyWith(color: colorScheme.error)));
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
                  return Center(
                    child: Text(
                      'No participants found',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRegistrations.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final registration = filteredRegistrations[index];
                    return _buildParticipantCard(registration, colorScheme, textTheme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search participants...',
          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildParticipantCard(Registration registration, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        title: Text(registration.fullName, style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        subtitle: Text(registration.email, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        trailing: _buildStatusChip(registration.paymentStatus, colorScheme, textTheme),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Phone', registration.phone, colorScheme, textTheme),
                _buildInfoRow('Gender', registration.gender, colorScheme, textTheme),
                _buildInfoRow('Location', registration.location, colorScheme, textTheme),
                _buildInfoRow('Registration Date',
                    registration.registrationDate.toString(), colorScheme, textTheme),
                if (registration.paymentStatus == PaymentStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.check, color: colorScheme.secondary),
                        label: Text('Approve', style: textTheme.labelLarge?.copyWith(color: colorScheme.secondary)),
                        onPressed: () => _updateStatus(
                            registration.id, PaymentStatus.approved),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.close, color: colorScheme.error),
                        label: Text('Reject', style: textTheme.labelLarge?.copyWith(color: colorScheme.error)),
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

  Widget _buildStatusChip(PaymentStatus status, ColorScheme colorScheme, TextTheme textTheme) {
    final colors = {
      PaymentStatus.pending: colorScheme.tertiary ?? colorScheme.primary,
      PaymentStatus.approved: colorScheme.secondary,
      PaymentStatus.rejected: colorScheme.error,
    };

    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
      ),
      backgroundColor: colors[status],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))),
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
