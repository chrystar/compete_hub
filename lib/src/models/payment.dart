import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, approved, rejected }

class Payment {
  final String id;
  final String eventId;
  final String userId;
  final String registrationId;
  final double amount;
  final String proofUrl;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? verifiedBy;
  final DateTime? verificationTime;

  Payment({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registrationId,
    required this.amount,
    required this.proofUrl,
    required this.status,
    required this.timestamp,
    this.verifiedBy,
    this.verificationTime,
  });

  factory Payment.fromJson(Map<String, dynamic> json, String id) {
    return Payment(
      id: id,
      eventId: json['eventId'],
      userId: json['userId'],
      registrationId: json['registrationId'],
      amount: json['amount'].toDouble(),
      proofUrl: json['proofUrl'],
      status: PaymentStatus.values.byName(json['status']),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      verifiedBy: json['verifiedBy'],
      verificationTime: json['verificationTime'] != null
          ? (json['verificationTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registrationId': registrationId,
      'amount': amount,
      'proofUrl': proofUrl,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'verifiedBy': verifiedBy,
      'verificationTime': verificationTime != null
          ? Timestamp.fromDate(verificationTime!)
          : null,
    };
  }
}
