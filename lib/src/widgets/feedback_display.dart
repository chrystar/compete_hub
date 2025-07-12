import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../models/feedback.dart';
import '../models/event.dart';
import '../providers/feedback_provider.dart';
import '../widgets/user_avatar.dart';
import '../widgets/feedback_form.dart';

class FeedbackDisplay extends StatelessWidget {
  final Event event;
  final bool showSubmitButton;
  final VoidCallback? onFeedbackSubmitted;

  const FeedbackDisplay({
    Key? key,
    required this.event,
    this.showSubmitButton = true,
    this.onFeedbackSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, feedbackProvider),
            const SizedBox(height: 16),
            _buildFeedbackSummary(context, feedbackProvider),
            const SizedBox(height: 20),
            _buildFeedbackList(context, feedbackProvider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FeedbackProvider feedbackProvider) {
    return Row(
      children: [
        const Text(
          'Event Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (showSubmitButton)
          FutureBuilder<bool>(
            future: feedbackProvider.canUserProvideFeedback(event.id),
            builder: (context, snapshot) {
              final canProvideFeedback = snapshot.data ?? false;
              
              if (!canProvideFeedback) return const SizedBox.shrink();
              
              return FutureBuilder<bool>(
                future: feedbackProvider.isEventOngoing(event.id),
                builder: (context, ongoingSnapshot) {
                  final isOngoing = ongoingSnapshot.data ?? false;
                  
                  return ElevatedButton.icon(
                    onPressed: () => _showFeedbackForm(context, isOngoing),
                    icon: Icon(isOngoing ? Icons.live_help : Icons.rate_review),
                    label: Text(isOngoing ? 'Live Feedback' : 'Add Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOngoing ? Colors.red : Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildFeedbackSummary(BuildContext context, FeedbackProvider feedbackProvider) {
    return StreamBuilder<FeedbackSummary>(
      stream: feedbackProvider.getEventFeedbackSummary(event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data!;
        
        if (summary.totalFeedbacks == 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No feedback yet. Be the first to share your experience!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildOverallRating(summary.overallRating),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${summary.totalFeedbacks} review${summary.totalFeedbacks == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (summary.duringEventCount > 0)
                          Text(
                            '${summary.duringEventCount} live • ${summary.postEventCount} post-event',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRatingBreakdown(summary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallRating(double rating) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                index < rating.floor() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(FeedbackSummary summary) {
    return Column(
      children: FeedbackType.values.map((type) {
        final average = summary.averageRatings[type] ?? 0.0;
        final count = summary.ratingCounts[type] ?? 0;
        
        if (count == 0) return const SizedBox.shrink();
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _getFeedbackTypeLabel(type),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: average / 5.0,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackList(BuildContext context, FeedbackProvider feedbackProvider) {
    return StreamBuilder<List<EventFeedback>>(
      stream: feedbackProvider.getEventFeedback(event.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbacks = snapshot.data!;
        
        if (feedbacks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...feedbacks.take(5).map((feedback) => _buildFeedbackCard(context, feedback, feedbackProvider)),
            if (feedbacks.length > 5)
              TextButton(
                onPressed: () => _showAllFeedback(context),
                child: const Text('View all feedback'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFeedbackCard(BuildContext context, EventFeedback feedback, FeedbackProvider feedbackProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                if (!feedback.isAnonymous)
                UserAvatar(
                  imageUrl: feedback.userAvatar,
                  name: feedback.userName,
                  size: 32,
                ),
              const SizedBox(width: 8),
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
              Row(
                children: [
                  Icon(
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
            ],
          ),
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback.comment!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () => feedbackProvider.toggleFeedbackUpvote(feedback.id),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up,
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
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _showFlagDialog(context, feedback, feedbackProvider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag,
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
          ),
        ],
      ),
    );
  }

  String _getFeedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.overall:
        return 'Overall';
      case FeedbackType.organization:
        return 'Organization';
      case FeedbackType.venue:
        return event.locationType == EventLocationType.online ? 'Platform' : 'Venue';
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

  void _showFeedbackForm(BuildContext context, bool isDuringEvent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackForm(
        event: event,
        isDuringEvent: isDuringEvent,
        onSubmitted: onFeedbackSubmitted,
      ),
    );
  }

  void _showAllFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllFeedbackScreen(event: event),
      ),
    );
  }

  void _showFlagDialog(BuildContext context, EventFeedback feedback, FeedbackProvider feedbackProvider) {
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
}

class AllFeedbackScreen extends StatelessWidget {
  final Event event;

  const AllFeedbackScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('All Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FeedbackDisplay(
          event: event,
          showSubmitButton: false,
        ),
      ),
    );
  }
}
