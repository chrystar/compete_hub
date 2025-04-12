import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Announcement {
  final String id;
  final String eventId;
  final String message;
  final DateTime timestamp;
  final String senderId;
  final List<String> readBy;

  bool get isRead => readBy.contains(FirebaseAuth.instance.currentUser?.uid);

  Announcement({
    required this.id,
    required this.eventId,
    required this.message,
    required this.timestamp,
    required this.senderId,
    required this.readBy,
  });

  factory Announcement.fromJson(Map<String, dynamic> json, String id) {
    return Announcement(
      id: id,
      eventId: json['eventId'],
      message: json['message'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      senderId: json['senderId'],
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderId': senderId,
      'readBy': readBy,
    };
  }
}
