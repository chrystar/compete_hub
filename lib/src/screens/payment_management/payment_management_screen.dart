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
    return StreamBuilder<List<Registration>>(
      stream: Provider.of<EventProvider>(context)
          .getRegistrationsByStatus(event.id, status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final registrations = snapshot.data ?? [];
        if (registrations.isEmpty) {
          return Center(
            child: Text(
              'No ${status.toString().split('.').last.toLowerCase()} registrations',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: registrations.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final registration = registrations[index];
            return Card(
              child: ListTile(
                title: Text(registration.fullName),
                subtitle: Text(registration.email),
                trailing: status == PaymentStatus.pending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateStatus(context,
                                registration.id, PaymentStatus.approved),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _updateStatus(context,
                                registration.id, PaymentStatus.rejected),
                          ),
                        ],
                      )
                    : Text(
                        status.toString().split('.').last,
                        style: TextStyle(
                          color: status == PaymentStatus.approved
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
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
}
