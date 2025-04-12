import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  final String id;
  final String eventId;
  final String player1;
  final String player2;
  final int round;
  final DateTime? scheduledTime;
  final String? winnerId;
  final Map<String, dynamic>? scores;

  Match({
    required this.id,
    required this.eventId,
    required this.player1,
    required this.player2,
    required this.round,
    this.scheduledTime,
    this.winnerId,
    this.scores,
  });

  factory Match.fromJson(Map<String, dynamic> json, String id) {
    return Match(
      id: id,
      eventId: json['eventId'],
      player1: json['player1'],
      player2: json['player2'],
      round: json['round'],
      scheduledTime: json['scheduledTime'] != null
          ? (json['scheduledTime'] as Timestamp).toDate()
          : null,
      winnerId: json['winnerId'],
      scores: json['scores'],
    );
  }
}
