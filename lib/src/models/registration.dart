import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { notRequired, pending, approved, rejected }

class Registration {
  final String id;
  final String eventId;
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String location;
  final DateTime registrationDate;
  final PaymentStatus paymentStatus;
  final String? paymentProofUrl;

  Registration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.location,
    required this.registrationDate,
    required this.paymentStatus,
    this.paymentProofUrl,
  });

  factory Registration.fromJson(Map<String, dynamic> json, String id) {
    return Registration(
      id: id,
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      registrationDate: (json['registrationDate'] as Timestamp).toDate(),
      paymentStatus: PaymentStatus.values[json['paymentStatus'] ?? 0],
      paymentProofUrl: json['paymentProofUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'location': location,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'paymentStatus': paymentStatus.index,
      'paymentProofUrl': paymentProofUrl,
    };
  }
}
