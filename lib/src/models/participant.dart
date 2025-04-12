import 'package:cloud_firestore/cloud_firestore.dart';

enum ParticipantStatus {
  pending,
  confirmed,
  checkedIn,
  disqualified,
}

class Participant {
  final String id;
  final String eventId;
  final String userId;
  final String name;
  final String email;
  final ParticipantStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime registrationDate;

  Participant({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.name,
    required this.email,
    required this.status,
    this.metadata,
    required this.registrationDate,
  });

  factory Participant.fromJson(Map<String, dynamic> json, String id) {
    return Participant(
      id: id,
      eventId: json['eventId'],
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      status: ParticipantStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      metadata: json['metadata'],
      registrationDate: (json['registrationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'name': name,
      'email': email,
      'status': status.toString(),
      'metadata': metadata,
      'registrationDate': Timestamp.fromDate(registrationDate),
    };
  }
}
