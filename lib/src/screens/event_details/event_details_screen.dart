import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/registration_form.dart';
import '../../widgets/feedback_display.dart';
import '../payment/payment_screen.dart';
import '../feedback/event_feedback_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.event.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFeedbackScreen(event: widget.event),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildFeedbackTab(),
        ],
      ),
      bottomNavigationBar: Consumer<EventProvider>(
        builder: (context, provider, _) {
          final isCreator = provider.isEventOrganizer(widget.event.organizerId);
          if (isCreator) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<bool>(
              stream: provider.isRegisteredForEventStream(widget.event.id),
              builder: (context, snapshot) {
                final isRegistered = snapshot.data ?? false;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRegistered ? Colors.green : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isRegistered
                      ? null
                      : () => _showRegistrationForm(context),
                  child: Text(
                    isRegistered ? 'Already Registered' : 'Register Now',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.event.description,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
          SizedBox(height: 24),
          _buildInfoSection('Date & Time', [
            'Starts: ${_formatDateTime(widget.event.startDateTime)}',
            'Ends: ${_formatDateTime(widget.event.endDateTime)}',
            'Registration Deadline: ${_formatDateTime(widget.event.entryDeadline)}',
          ]),
          _buildInfoSection('Location', [
            widget.event.locationType.toString().split('.').last,
            if (widget.event.location != null) widget.event.location!,
          ]),
          _buildInfoSection('Tournament Details', [
            'Format: ${widget.event.format.toString().split('.').last}',
            'Max Participants: ${widget.event.maxParticipants}',
            'Entry Fee: ${widget.event.feeType == EventFeeType.free ? 'Free' : '\$${widget.event.entryFee}'}',
          ]),
          if (widget.event.eligibilityRules != null)
            _buildInfoSection(
                'Eligibility Rules', [widget.event.eligibilityRules!]),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return FutureBuilder<bool>(
          future: feedbackProvider.canUserProvideFeedback(widget.event.id),
          builder: (context, snapshot) {
            final canProvideFeedback = snapshot.data ?? false;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FeedbackDisplay(
                event: widget.event,
                showSubmitButton: canProvideFeedback,
                onFeedbackSubmitted: () {
                  // Refresh feedback data
                  setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showRegistrationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegistrationForm(
        event: widget.event,
        onSubmit: (formData) async {
          try {
            final result =
                await Provider.of<EventProvider>(context, listen: false)
                    .registerForEvent(
              widget.event.id,
              fullName: formData['fullName']!,
              email: formData['email']!,
              phone: formData['phone']!,
              gender: formData['gender']!,
              location: formData['location']!,
            );

            if (result['feeType'] == EventFeeType.paid && mounted) {
              Navigator.pop(context); // Close form
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    event: widget.event,
                    registrationId: result['registrationId'],
                    onPaymentProofUploaded: (File file) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment proof uploaded successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Handle the uploaded file if needed
                    },
                  ),
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully registered!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...details.map((detail) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(detail, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )),
        SizedBox(height: 24),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
