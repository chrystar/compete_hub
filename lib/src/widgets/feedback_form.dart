import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_colors.dart';
import '../models/feedback.dart';
import '../models/event.dart';
import '../providers/feedback_provider.dart';

class FeedbackForm extends StatefulWidget {
  final Event event;
  final bool isDuringEvent;
  final EventFeedback? existingFeedback;
  final VoidCallback? onSubmitted;

  const FeedbackForm({
    Key? key,
    required this.event,
    this.isDuringEvent = false,
    this.existingFeedback,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  Map<FeedbackType, int> _ratings = {};
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize ratings
    for (FeedbackType type in FeedbackType.values) {
      _ratings[type] = widget.existingFeedback?.ratings[type] ?? 5;
    }
    
    // If editing existing feedback
    if (widget.existingFeedback != null) {
      _commentController.text = widget.existingFeedback!.comment ?? '';
      _isAnonymous = widget.existingFeedback!.isAnonymous;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRatingSection(),
                    const SizedBox(height: 20),
                    _buildCommentSection(),
                    const SizedBox(height: 20),
                    _buildOptionsSection(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.isDuringEvent ? Icons.live_help : Icons.rate_review,
          color: AppColors.lightPrimary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingFeedback != null ? 'Edit Feedback' : 
                widget.isDuringEvent ? 'Live Feedback' : 'Event Feedback',
                style: const TextStyle(
                  color: AppColors.lightOnSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.event.name,
                style: TextStyle(
                  color: AppColors.lightOnSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.lightOnSurface),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate Your Experience',
          style: TextStyle(
            color: AppColors.lightOnSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...FeedbackType.values.map((type) => _buildRatingRow(type)),
      ],
    );
  }

  Widget _buildRatingRow(FeedbackType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getFeedbackTypeLabel(type),
              style: const TextStyle(
                color: AppColors.lightOnSurface,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _ratings[type] = rating;
                    });
                  },
                  child: Icon(
                    rating <= (_ratings[type] ?? 0) ? Icons.star : Icons.star_border,
                    color: rating <= (_ratings[type] ?? 0) 
                        ? AppColors.lightSecondary 
                        : AppColors.lightOnSurfaceVariant,
                    size: 32,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Comments',
          style: TextStyle(
            color: AppColors.lightOnSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: widget.isDuringEvent 
                ? 'Share your thoughts about the ongoing event...'
                : 'Tell us about your experience...',
            hintStyle: const TextStyle(color: AppColors.lightOnSurfaceVariant),
            filled: true,
            fillColor: AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
            ),
          ),
          style: const TextStyle(color: AppColors.lightOnSurface),
          validator: (value) {
            if (widget.isDuringEvent && (value == null || value.trim().isEmpty)) {
              return 'Please provide some feedback for live events';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Submit anonymously',
            style: TextStyle(color: AppColors.lightOnSurface),
          ),
          subtitle: const Text(
            'Your name will not be shown with this feedback',
            style: TextStyle(color: AppColors.lightOnSurfaceVariant),
          ),
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
          activeColor: AppColors.lightPrimary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lightOnPrimary),
                ),
              )
            : Text(
                widget.existingFeedback != null ? 'Update Feedback' : 'Submit Feedback',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _getFeedbackTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.overall:
        return 'Overall Experience';
      case FeedbackType.organization:
        return 'Organization';
      case FeedbackType.venue:
        return widget.event.locationType == EventLocationType.online 
            ? 'Platform/Tech' : 'Venue';
      case FeedbackType.content:
        return 'Content Quality';
      case FeedbackType.communication:
        return 'Communication';
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      
      if (widget.existingFeedback != null) {
        // Update existing feedback
        await feedbackProvider.updateFeedback(
          feedbackId: widget.existingFeedback!.id,
          ratings: _ratings,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );
      } else {
        // Submit new feedback
        await feedbackProvider.submitFeedback(
          eventId: widget.event.id,
          ratings: _ratings,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
          isAnonymous: _isAnonymous,
          isDuringEvent: widget.isDuringEvent,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingFeedback != null 
                  ? 'Feedback updated successfully!' 
                  : 'Thank you for your feedback!',
            ),
            backgroundColor: AppColors.lightSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
