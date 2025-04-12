import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String id;
  final String title;
  final String description;
  final String eventId;
  final String organizerId;
  final DateTime timestamp;
  final String? imageUrl;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.eventId,
    required this.organizerId,
    required this.timestamp,
    this.imageUrl,
  });

  factory News.fromJson(Map<String, dynamic> json, String id) {
    return News(
      id: id,
      title: json['title'],
      description: json['description'],
      eventId: json['eventId'],
      organizerId: json['organizerId'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'eventId': eventId,
      'organizerId': organizerId,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
    };
  }
}
