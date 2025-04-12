import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../models/event.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final Event event;

  const PaymentVerificationScreen({super.key, required this.event});

  @override
  State<PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('Payment Verifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PaymentList(event: widget.event, status: PaymentStatus.pending),
          _PaymentList(event: widget.event, status: PaymentStatus.approved),
          _PaymentList(event: widget.event, status: PaymentStatus.rejected),
        ],
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
    return StreamBuilder<List<Payment>>(
      stream: Provider.of<PaymentProvider>(context)
          .getPaymentsByStatus(event.id, status),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snapshot.data!;
        if (payments.isEmpty) {
          return Center(
            child: Text(
              'No ${status.name} payments',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return Card(
              child: ListTile(
                title: Text('Amount: \$${payment.amount}'),
                subtitle: Text('Date: ${_formatDate(payment.timestamp)}'),
                trailing: status == PaymentStatus.pending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                _verifyPayment(context, payment, true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _verifyPayment(context, payment, false),
                          ),
                        ],
                      )
                    : null,
                onTap: () => _showPaymentDetails(context, payment),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentDetails(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(payment.proofUrl),
            const SizedBox(height: 16),
            Text('Amount: \$${payment.amount}'),
            Text('Date: ${_formatDate(payment.timestamp)}'),
            if (payment.verificationTime != null)
              Text('Verified: ${_formatDate(payment.verificationTime!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPayment(
      BuildContext context, Payment payment, bool approved) async {
    try {
      await Provider.of<PaymentProvider>(context, listen: false)
          .verifyPayment(payment.id, approved);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment ${approved ? 'approved' : 'rejected'}')),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
