import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../models/registration.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';

class PaymentManagementScreen extends StatelessWidget {
  final Event event;

  const PaymentManagementScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (event.feeType == EventFeeType.free) {
      return Scaffold(
        backgroundColor: colorScheme.primary,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: const Text('Payment Management'),
        ),
        body: Center(
          child: Text(
            'Payment management not available for free events',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: const Text('Payment Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PaymentList(event: event, status: PaymentStatus.pending),
            _PaymentList(event: event, status: PaymentStatus.approved),
            _PaymentList(event: event, status: PaymentStatus.rejected),
          ],
        ),
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  final Event event;
  final PaymentStatus status;

  const _PaymentList({required this.event, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    print(
        'Building PaymentList for event: ${event.id}, status: ${status.name}');
    return StreamBuilder<List<Registration>>(
      stream: Provider.of<EventProvider>(context)
          .getRegistrationsByStatus(event.id, status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Stream error: ${snapshot.error}'); // Add debug print
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final registrations = snapshot.data ?? [];
        print('Received registrations: ${registrations.length}'); // Debug print
        registrations.forEach((reg) {
          print(
              'Registration - Name: ${reg.fullName}, Status: ${reg.paymentStatus}');
        });

        if (registrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == PaymentStatus.pending
                      ? Icons.pending_actions
                      : status == PaymentStatus.approved
                          ? Icons.check_circle
                          : Icons.cancel,
                  size: 64,
                  color: colorScheme.onPrimary.withOpacity(0.54),
                ),
                const SizedBox(height: 16),
                Text(
                  'No  ${status.toString().split('.').last.toLowerCase()} registrations',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: registrations.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final registration = registrations[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ExpansionTile(
                title: Text(
                  registration.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${registration.email}'),
                    Text('Phone: ${registration.phone}'),
                  ],
                ),
                trailing: _buildStatusIndicator(registration),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Gender', registration.gender),
                        _buildInfoRow('Location', registration.location),
                        _buildInfoRow('Registered',
                            _formatDate(registration.registrationDate)),
                        if (status == PaymentStatus.pending)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: colorScheme.onSecondary,
                                ),
                                onPressed: () => _showConfirmationDialog(
                                  context,
                                  registration,
                                  PaymentStatus.approved,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.cancel),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                  foregroundColor: colorScheme.onError,
                                ),
                                onPressed: () => _showConfirmationDialog(
                                  context,
                                  registration,
                                  PaymentStatus.rejected,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIndicator(Registration registration) {
    // context is not available here, so pass colorScheme from build
    // Instead, require context as a parameter
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        Color statusColor;
        switch (registration.paymentStatus) {
          case PaymentStatus.approved:
            statusColor = colorScheme.secondary;
            break;
          case PaymentStatus.rejected:
            statusColor = colorScheme.error;
            break;
          case PaymentStatus.pending:
          default:
            statusColor = colorScheme.tertiary ?? colorScheme.primary;
            break;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            registration.paymentStatus.toString().split('.').last,
            style: TextStyle(color: statusColor),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    Registration registration,
    PaymentStatus newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${newStatus.toString().split('.').last}'),
        content: Text(
          'Are you sure you want to ${newStatus.toString().split('.').last.toLowerCase()} '
          'payment for ${registration.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _updateStatus(context, registration.id, newStatus);
    }
  }

  Future<void> _updateStatus(BuildContext context, String registrationId,
      PaymentStatus newStatus) async {
    try {
      await Provider.of<EventProvider>(context, listen: false)
          .updateRegistrationStatus(registrationId, newStatus);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Registration ${newStatus.toString().split('.').last}'),
            backgroundColor:
                newStatus == PaymentStatus.approved
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
