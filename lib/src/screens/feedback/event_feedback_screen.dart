import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_colors.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        title: Text(
          'Event Feedback',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.onBackground),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onBackground,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'All Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(colorScheme, textTheme),
          _buildAllReviewsTab(colorScheme, textTheme),
        ],
      ),
      floatingActionButton: widget.canSubmitFeedback && _userFeedback == null
          ? FloatingActionButton.extended(
              onPressed: _showFeedbackForm,
              backgroundColor: _isEventOngoing ? colorScheme.error : colorScheme.secondary,
              icon: Icon(_isEventOngoing ? Icons.live_help : Icons.rate_review, color: colorScheme.onSecondary),
              label: Text(_isEventOngoing ? 'Live Feedback' : 'Add Review', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSecondary)),
            )
          : _userFeedback != null
              ? FloatingActionButton.extended(
                  onPressed: _editFeedback,
                  backgroundColor: colorScheme.primary,
                  icon: Icon(Icons.edit, color: colorScheme.onPrimary),
                  label: Text('Edit Review', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
                )
              : null,
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventInfo(colorScheme, textTheme),
          const SizedBox(height: 20),
          if (_userFeedback != null) _buildUserFeedbackCard(colorScheme, textTheme),
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

  Widget _buildAllReviewsTab(ColorScheme colorScheme, TextTheme textTheme) {
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
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No feedback yet',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share your experience!',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
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
                return _buildDetailedFeedbackCard(feedbacks[index], colorScheme, textTheme);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEventInfo(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.name,
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.event.description,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _isEventOngoing ? Icons.live_tv : Icons.event,
                color: _isEventOngoing ? colorScheme.error : colorScheme.onPrimaryContainer.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isEventOngoing ? 'Event is ongoing' : 'Event completed',
                style: textTheme.bodySmall?.copyWith(
                  color: _isEventOngoing ? colorScheme.error : colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserFeedbackCard(ColorScheme colorScheme, TextTheme textTheme) {
    if (_userFeedback == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Feedback',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _userFeedback!.overallRating.toStringAsFixed(1),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
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
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Submitted ${_formatTimeAgo(_userFeedback!.timestamp)}',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFeedbackCard(EventFeedback feedback, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: feedback.isDuringEvent 
            ? Border.all(color: colorScheme.error.withOpacity(0.5), width: 1)
            : Border.all(color: colorScheme.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.onSurface.withOpacity(0.2),
                child: Text(
                  feedback.isAnonymous 
                      ? 'A'
                      : feedback.userName.isNotEmpty 
                          ? feedback.userName[0].toUpperCase()
                          : '?',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
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
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (feedback.isDuringEvent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'LIVE',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
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
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedback.overallRating.toStringAsFixed(1),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRatingDetails(feedback, colorScheme, textTheme),
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              feedback.comment!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildFeedbackActions(feedback, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildRatingDetails(EventFeedback feedback, ColorScheme colorScheme, TextTheme textTheme) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: feedback.ratings.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getFeedbackTypeLabel(entry.key),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < entry.value ? Icons.star : Icons.star_border,
                    color: colorScheme.secondary,
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

  Widget _buildFeedbackActions(EventFeedback feedback, ColorScheme colorScheme, TextTheme textTheme) {
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
                        ? colorScheme.primary 
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${feedback.upvotes.length}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
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
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'Report',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
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
        title: Text('Report Feedback'),
        content: Text('Why are you reporting this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
              await feedbackProvider.flagFeedback(feedback.id, 'Inappropriate content');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Feedback reported')),
              );
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _onFeedbackSubmitted() {
    _loadUserFeedback();
  }
}
