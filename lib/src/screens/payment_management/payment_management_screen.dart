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
    if (event.feeType == EventFeeType.free) {
      return Scaffold(
        backgroundColor: AppColors.lightPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.lightPrimary,
          title: const Text('Payment Management'),
        ),
        body: const Center(
          child: Text(
            'Payment management not available for free events',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.lightPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.lightPrimary,
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
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.toString().split('.').last.toLowerCase()} registrations',
                  style: const TextStyle(color: Colors.white),
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
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
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
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
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
    // Update to use registration's actual status instead of tab status
    final statusColor = registration.paymentStatus == PaymentStatus.approved
        ? Colors.green
        : registration.paymentStatus == PaymentStatus.rejected
            ? Colors.red
            : Colors.orange;

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
                newStatus == PaymentStatus.approved ? Colors.green : Colors.red,
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
