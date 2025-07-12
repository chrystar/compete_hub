import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/feedback.dart';
import '../models/event.dart';

class FeedbackProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Submit feedback for an event
  Future<String> submitFeedback({
    required String eventId,
    required Map<FeedbackType, int> ratings,
    String? comment,
    bool isAnonymous = false,
    bool isDuringEvent = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      _setLoading(true);

      // Check if user has already submitted feedback
      final existingFeedback = await _firestore
          .collection('event_feedback')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingFeedback.docs.isNotEmpty) {
        throw Exception('You have already submitted feedback for this event');
      }

      // Check if user is registered for the event
      final registrationCheck = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (registrationCheck.docs.isEmpty) {
        throw Exception('You must be registered for the event to provide feedback');
      }

      final feedback = EventFeedback(
        id: '',
        eventId: eventId,
        userId: user.uid,
        userName: isAnonymous ? 'Anonymous' : user.displayName ?? user.email ?? 'Unknown User',
        userAvatar: isAnonymous ? null : user.photoURL,
        ratings: ratings,
        comment: comment,
        timestamp: DateTime.now(),
        isAnonymous: isAnonymous,
        isDuringEvent: isDuringEvent,
      );

      final docRef = await _firestore
          .collection('event_feedback')
          .add(feedback.toJson());

      // Update event feedback summary in real-time
      await _updateEventFeedbackSummary(eventId);

      _setLoading(false);
      notifyListeners();
      
      return docRef.id;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Update existing feedback
  Future<void> updateFeedback({
    required String feedbackId,
    required Map<FeedbackType, int> ratings,
    String? comment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      _setLoading(true);

      // Verify user owns this feedback
      final feedbackDoc = await _firestore
          .collection('event_feedback')
          .doc(feedbackId)
          .get();

      if (!feedbackDoc.exists) {
        throw Exception('Feedback not found');
      }

      final feedback = EventFeedback.fromJson(feedbackDoc.data()!, feedbackDoc.id);
      
      if (feedback.userId != user.uid) {
        throw Exception('You can only update your own feedback');
      }

      await _firestore
          .collection('event_feedback')
          .doc(feedbackId)
          .update({
        'ratings': ratings.map((key, value) => MapEntry(key.name, value)),
        'comment': comment,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      // Update event feedback summary
      await _updateEventFeedbackSummary(feedback.eventId);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw Exception('Failed to update feedback: $e');
    }
  }

  // Get all feedback for an event
  Stream<List<EventFeedback>> getEventFeedback(String eventId, {bool includeFlagged = false}) {
    return _firestore
        .collection('event_feedback')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      var feedbacks = snapshot.docs
          .map((doc) => EventFeedback.fromJson(doc.data(), doc.id))
          .toList();

      // Filter by status in the app instead of the query to avoid index requirements
      if (!includeFlagged) {
        feedbacks = feedbacks.where((f) => f.status == FeedbackStatus.active).toList();
      }

      // Sort by timestamp in descending order (newest first)
      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedbacks;
    });
  }

  // Get feedback summary for an event
  Stream<FeedbackSummary> getEventFeedbackSummary(String eventId) {
    return getEventFeedback(eventId).map((feedbacks) => 
        FeedbackSummary.fromFeedbacks(eventId, feedbacks));
  }

  // Get user's feedback for an event
  Future<EventFeedback?> getUserFeedbackForEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _firestore
          .collection('event_feedback')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return EventFeedback.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      print('Error getting user feedback: $e');
      return null;
    }
  }

  // Check if user can provide feedback (is registered and event has started)
  Future<bool> canUserProvideFeedback(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user is registered
      final registrationCheck = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (registrationCheck.docs.isEmpty) return false;

      // Check if user has already provided feedback
      final feedbackCheck = await _firestore
          .collection('event_feedback')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: user.uid)
          .get();

      return feedbackCheck.docs.isEmpty;
    } catch (e) {
      print('Error checking feedback eligibility: $e');
      return false;
    }
  }

  // Check if event is currently ongoing
  Future<bool> isEventOngoing(String eventId) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) return false;

      final event = Event.fromJson(eventDoc.data()!, eventDoc.id);
      final now = DateTime.now();
      
      return now.isAfter(event.startDateTime) && now.isBefore(event.endDateTime);
    } catch (e) {
      print('Error checking if event is ongoing: $e');
      return false;
    }
  }

  // Upvote feedback
  Future<void> toggleFeedbackUpvote(String feedbackId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final feedbackRef = _firestore.collection('event_feedback').doc(feedbackId);
      final feedbackDoc = await feedbackRef.get();
      
      if (!feedbackDoc.exists) throw Exception('Feedback not found');

      final feedback = EventFeedback.fromJson(feedbackDoc.data()!, feedbackDoc.id);
      final upvotes = List<String>.from(feedback.upvotes);

      if (upvotes.contains(user.uid)) {
        upvotes.remove(user.uid);
      } else {
        upvotes.add(user.uid);
      }

      await feedbackRef.update({'upvotes': upvotes});
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to toggle upvote: $e');
    }
  }

  // Flag inappropriate feedback
  Future<void> flagFeedback(String feedbackId, String reason) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final feedbackRef = _firestore.collection('event_feedback').doc(feedbackId);
      final feedbackDoc = await feedbackRef.get();
      
      if (!feedbackDoc.exists) throw Exception('Feedback not found');

      final feedback = EventFeedback.fromJson(feedbackDoc.data()!, feedbackDoc.id);
      final flags = List<String>.from(feedback.flags);

      if (!flags.contains(user.uid)) {
        flags.add(user.uid);
        
        // Auto-hide if flagged by multiple users (threshold: 3 flags)
        FeedbackStatus newStatus = feedback.status;
        if (flags.length >= 3) {
          newStatus = FeedbackStatus.flagged;
        }

        await feedbackRef.update({
          'flags': flags,
          'status': newStatus.name,
        });

        // Create a flag report
        await _firestore.collection('feedback_reports').add({
          'feedbackId': feedbackId,
          'reporterId': user.uid,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to flag feedback: $e');
    }
  }

  // Get feedback analytics for organizers
  Stream<Map<String, dynamic>> getOrganizerFeedbackAnalytics(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .asyncMap((eventSnapshot) async {
      final eventIds = eventSnapshot.docs.map((doc) => doc.id).toList();
      
      if (eventIds.isEmpty) {
        return {
          'totalEvents': 0,
          'totalFeedbacks': 0,
          'averageRating': 0.0,
          'ratingDistribution': <int, int>{},
          'recentFeedbacks': <EventFeedback>[],
        };
      }

      final feedbackSnapshot = await _firestore
          .collection('event_feedback')
          .where('eventId', whereIn: eventIds)
          .where('status', isEqualTo: FeedbackStatus.active.name)
          .get();

      final feedbacks = feedbackSnapshot.docs
          .map((doc) => EventFeedback.fromJson(doc.data(), doc.id))
          .toList();

      // Calculate analytics
      final totalFeedbacks = feedbacks.length;
      double totalRating = 0.0;
      final Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final feedback in feedbacks) {
        final overallRating = feedback.overallRating.round();
        totalRating += feedback.overallRating;
        ratingDistribution[overallRating] = (ratingDistribution[overallRating] ?? 0) + 1;
      }

      final averageRating = totalFeedbacks > 0 ? totalRating / totalFeedbacks : 0.0;

      // Get recent feedbacks (last 10)
      final recentFeedbacks = feedbacks
          .where((f) => f.comment != null && f.comment!.isNotEmpty)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return {
        'totalEvents': eventSnapshot.docs.length,
        'totalFeedbacks': totalFeedbacks,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'recentFeedbacks': recentFeedbacks.take(10).toList(),
      };
    });
  }

  // Delete feedback (only by owner or admin)
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User must be authenticated');

      final feedbackDoc = await _firestore
          .collection('event_feedback')
          .doc(feedbackId)
          .get();

      if (!feedbackDoc.exists) throw Exception('Feedback not found');

      final feedback = EventFeedback.fromJson(feedbackDoc.data()!, feedbackDoc.id);
      
      if (feedback.userId != user.uid) {
        throw Exception('You can only delete your own feedback');
      }

      await _firestore.collection('event_feedback').doc(feedbackId).delete();
      
      // Update event feedback summary
      await _updateEventFeedbackSummary(feedback.eventId);
      
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Update event feedback summary in Firestore for quick access
  Future<void> _updateEventFeedbackSummary(String eventId) async {
    try {
      final feedbacks = await _firestore
          .collection('event_feedback')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: FeedbackStatus.active.name)
          .get();

      final feedbackList = feedbacks.docs
          .map((doc) => EventFeedback.fromJson(doc.data(), doc.id))
          .toList();

      final summary = FeedbackSummary.fromFeedbacks(eventId, feedbackList);

      await _firestore
          .collection('event_feedback_summary')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'totalFeedbacks': summary.totalFeedbacks,
        'averageRatings': summary.averageRatings.map((key, value) => MapEntry(key.name, value)),
        'ratingCounts': summary.ratingCounts.map((key, value) => MapEntry(key.name, value)),
        'overallRating': summary.overallRating,
        'duringEventCount': summary.duringEventCount,
        'postEventCount': summary.postEventCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating feedback summary: $e');
    }
  }
}
