import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/feedback.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/feedback_display.dart';
import '../../widgets/feedback_form.dart';

class EventFeedbackScreen extends StatefulWidget {
  final Event event;
  final bool canSubmitFeedback;

  const EventFeedbackScreen({
    Key? key,
    required this.event,
    this.canSubmitFeedback = true,
  }) : super(key: key);

  @override
  State<EventFeedbackScreen> createState() => _EventFeedbackScreenState();
}

class _EventFeedbackScreenState extends State<EventFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEventOngoing = false;
  EventFeedback? _userFeedback;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEventStatus();
    _loadUserFeedback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEventStatus() async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final isOngoing = await feedbackProvider.isEventOngoing(widget.event.id);
    if (mounted) {
      setState(() {
        _isEventOngoing = isOngoing;
      });
    }
  }

  Future<void> _loadUserFeedback() async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final feedback = await feedbackProvider.getUserFeedbackForEvent(widget.event.id);
    if (mounted) {
      setState(() {
        _userFeedback = feedback;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Event Feedback',
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'All Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAllReviewsTab(),
        ],
      ),
      floatingActionButton: widget.canSubmitFeedback && _userFeedback == null
          ? FloatingActionButton.extended(
              onPressed: _showFeedbackForm,
              backgroundColor: _isEventOngoing ? Colors.red : Colors.amber,
              icon: Icon(_isEventOngoing ? Icons.live_help : Icons.rate_review),
              label: Text(_isEventOngoing ? 'Live Feedback' : 'Add Review'),
            )
          : _userFeedback != null
              ? FloatingActionButton.extended(
                  onPressed: _editFeedback,
                  backgroundColor: Colors.blue,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Review'),
                )
              : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventInfo(),
          const SizedBox(height: 20),
          if (_userFeedback != null) _buildUserFeedbackCard(),
          if (_userFeedback != null) const SizedBox(height: 20),
          FeedbackDisplay(
            event: widget.event,
            showSubmitButton: false,
            onFeedbackSubmitted: _onFeedbackSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildAllReviewsTab() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return StreamBuilder<List<EventFeedback>>(
          stream: feedbackProvider.getEventFeedback(widget.event.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbacks = snapshot.data!;

            if (feedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No feedback yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your experience!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                return _buildDetailedFeedbackCard(feedbacks[index]);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.event.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),            Row(
              children: [
                Icon(
                  _isEventOngoing ? Icons.live_tv : Icons.event,
                  color: _isEventOngoing ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEventOngoing ? 'Event is ongoing' : 'Event completed',
                  style: TextStyle(
                    color: _isEventOngoing ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUserFeedbackCard() {
    if (_userFeedback == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Feedback',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _userFeedback!.overallRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_userFeedback!.comment != null && _userFeedback!.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _userFeedback!.comment!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Submitted ${_formatTimeAgo(_userFeedback!.timestamp)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeedbackCard(EventFeedback feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: feedback.isDuringEvent 
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  feedback.isAnonymous 
                      ? 'A'
                      : feedback.userName.isNotEmpty 
                          ? feedback.userName[0].toUpperCase()
                          : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feedback.isAnonymous ? 'Anonymous' : feedback.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (feedback.isDuringEvent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTimeAgo(feedback.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedback.overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRatingDetails(feedback),
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              feedback.comment!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildFeedbackActions(feedback),
        ],
      ),
    );
  }

  Widget _buildRatingDetails(EventFeedback feedback) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: feedback.ratings.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getFeedbackTypeLabel(entry.key),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < entry.value ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  );
                }),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackActions(EventFeedback feedback) {
    return Row(
      children: [
        Consumer<FeedbackProvider>(
          builder: (context, feedbackProvider, child) {
            return InkWell(
              onTap: () => feedbackProvider.toggleFeedbackUpvote(feedback.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    feedback.upvotes.isNotEmpty 
                        ? Icons.thumb_up 
                        : Icons.thumb_up_outlined,
                    size: 16,
                    color: feedback.upvotes.isNotEmpty 
                        ? Colors.blue 
                        : Colors.white.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${feedback.upvotes.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        InkWell(
          onTap: () => _showFlagDialog(feedback),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'Report',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFeedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.overall:
        return 'Overall';
      case FeedbackType.organization:
        return 'Organization';
      case FeedbackType.venue:
        return widget.event.locationType == EventLocationType.online ? 'Platform' : 'Venue';
      case FeedbackType.content:
        return 'Content';
      case FeedbackType.communication:
        return 'Communication';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }

  void _showFeedbackForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackForm(
        event: widget.event,
        isDuringEvent: _isEventOngoing,
        onSubmitted: _onFeedbackSubmitted,
      ),
    );
  }

  void _editFeedback() {
    if (_userFeedback == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackForm(
        event: widget.event,
        existingFeedback: _userFeedback,
        isDuringEvent: _isEventOngoing,
        onSubmitted: _onFeedbackSubmitted,
      ),
    );
  }

  void _showFlagDialog(EventFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Feedback'),
        content: const Text('Why are you reporting this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
              await feedbackProvider.flagFeedback(feedback.id, 'Inappropriate content');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _onFeedbackSubmitted() {
    _loadUserFeedback();
  }
}
