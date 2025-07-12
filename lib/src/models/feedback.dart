import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackType {
  overall,
  organization,
  venue,
  content,
  communication
}

enum FeedbackStatus {
  active,
  hidden,
  flagged
}

class EventFeedback {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final Map<FeedbackType, int> ratings; // 1-5 star ratings
  final String? comment;
  final DateTime timestamp;
  final bool isAnonymous;
  final FeedbackStatus status;
  final bool isDuringEvent; // true if submitted during event, false if post-event
  final List<String> upvotes; // user IDs who upvoted this feedback
  final List<String> flags; // user IDs who flagged this feedback

  EventFeedback({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.ratings,
    this.comment,
    required this.timestamp,
    this.isAnonymous = false,
    this.status = FeedbackStatus.active,
    this.isDuringEvent = false,
    this.upvotes = const [],
    this.flags = const [],
  });

  double get overallRating {
    if (ratings.isEmpty) return 0.0;
    double sum = ratings.values.fold(0.0, (prev, rating) => prev + rating);
    return sum / ratings.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'ratings': ratings.map((key, value) => MapEntry(key.name, value)),
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAnonymous': isAnonymous,
      'status': status.name,
      'isDuringEvent': isDuringEvent,
      'upvotes': upvotes,
      'flags': flags,
    };
  }

  factory EventFeedback.fromJson(Map<String, dynamic> json, String id) {
    final ratingsMap = <FeedbackType, int>{};
    if (json['ratings'] != null) {
      (json['ratings'] as Map<String, dynamic>).forEach((key, value) {
        final feedbackType = FeedbackType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => FeedbackType.overall,
        );
        ratingsMap[feedbackType] = value as int;
      });
    }

    return EventFeedback(
      id: id,
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      ratings: ratingsMap,
      comment: json['comment'],
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnonymous: json['isAnonymous'] ?? false,
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FeedbackStatus.active,
      ),
      isDuringEvent: json['isDuringEvent'] ?? false,
      upvotes: List<String>.from(json['upvotes'] ?? []),
      flags: List<String>.from(json['flags'] ?? []),
    );
  }

  EventFeedback copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userAvatar,
    Map<FeedbackType, int>? ratings,
    String? comment,
    DateTime? timestamp,
    bool? isAnonymous,
    FeedbackStatus? status,
    bool? isDuringEvent,
    List<String>? upvotes,
    List<String>? flags,
  }) {
    return EventFeedback(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      ratings: ratings ?? this.ratings,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      isDuringEvent: isDuringEvent ?? this.isDuringEvent,
      upvotes: upvotes ?? this.upvotes,
      flags: flags ?? this.flags,
    );
  }
}

class FeedbackSummary {
  final String eventId;
  final int totalFeedbacks;
  final Map<FeedbackType, double> averageRatings;
  final Map<FeedbackType, int> ratingCounts;
  final double overallRating;
  final int duringEventCount;
  final int postEventCount;

  FeedbackSummary({
    required this.eventId,
    required this.totalFeedbacks,
    required this.averageRatings,
    required this.ratingCounts,
    required this.overallRating,
    required this.duringEventCount,
    required this.postEventCount,
  });

  factory FeedbackSummary.fromFeedbacks(String eventId, List<EventFeedback> feedbacks) {
    final activeFeedbacks = feedbacks.where((f) => f.status == FeedbackStatus.active).toList();
    
    if (activeFeedbacks.isEmpty) {
      return FeedbackSummary(
        eventId: eventId,
        totalFeedbacks: 0,
        averageRatings: {},
        ratingCounts: {},
        overallRating: 0.0,
        duringEventCount: 0,
        postEventCount: 0,
      );
    }

    final Map<FeedbackType, List<int>> ratingsByType = {};
    
    // Collect all ratings by type
    for (final feedback in activeFeedbacks) {
      feedback.ratings.forEach((type, rating) {
        ratingsByType.putIfAbsent(type, () => []);
        ratingsByType[type]!.add(rating);
      });
    }

    // Calculate averages
    final Map<FeedbackType, double> averageRatings = {};
    final Map<FeedbackType, int> ratingCounts = {};
    
    ratingsByType.forEach((type, ratings) {
      averageRatings[type] = ratings.reduce((a, b) => a + b) / ratings.length;
      ratingCounts[type] = ratings.length;
    });

    // Calculate overall rating
    double overallSum = 0.0;
    int overallCount = 0;
    
    for (final feedback in activeFeedbacks) {
      overallSum += feedback.overallRating;
      overallCount++;
    }
    
    final overallRating = overallCount > 0 ? overallSum / overallCount : 0.0;

    return FeedbackSummary(
      eventId: eventId,
      totalFeedbacks: activeFeedbacks.length,
      averageRatings: averageRatings,
      ratingCounts: ratingCounts,
      overallRating: overallRating,
      duringEventCount: activeFeedbacks.where((f) => f.isDuringEvent).length,
      postEventCount: activeFeedbacks.where((f) => !f.isDuringEvent).length,
    );
  }
}
