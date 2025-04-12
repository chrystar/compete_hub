import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compete_hub/src/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitPaymentProof({
    required String eventId,
    required String registrationId,
    required File proofImage,
    required double amount,
  }) async {
    try {
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final event = Event.fromJson(eventDoc.data()!, eventDoc.id);

      // Convert image to bytes
      final imageBytes = await proofImage.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Create payment record
      final paymentDoc = await _firestore.collection('payments').add({
        'eventId': eventId,
        'registrationId': registrationId,
        'amount': amount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'imageBase64': imageBase64,
      });

      // Send to organizer's email if available
      if (event.organizerEmail.isNotEmpty) {
        await _sendEmailWithProof(
          event.organizerEmail,
          event.name,
          imageBase64,
          amount,
          paymentDoc.id,
        );
      }

      // Send to WhatsApp if available
      if (event.organizerWhatsApp.isNotEmpty) {
        await _sendWhatsAppMessage(
          event.organizerWhatsApp,
          event.name,
          imageBase64,
          amount,
          paymentDoc.id,
        );
      }
    } catch (e) {
      throw Exception('Failed to submit payment: $e');
    }
  }

  Future<void> _sendEmailWithProof(
    String email,
    String eventName,
    String imageBase64,
    double amount,
    String paymentId,
  ) async {
    try {
      final functionUrl =
          'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendPaymentEmail';
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'eventName': eventName,
          'imageBase64': imageBase64,
          'amount': amount,
          'paymentId': paymentId,
        }),
      );

      if (response.statusCode != 200) throw Exception(response.body);
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  Future<void> _sendWhatsAppMessage(
    String phone,
    String eventName,
    String imageBase64,
    double amount,
    String paymentId,
  ) async {
    try {
      final functionUrl =
          'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/sendWhatsAppMessage';
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'eventName': eventName,
          'imageBase64': imageBase64,
          'amount': amount,
          'paymentId': paymentId,
        }),
      );

      if (response.statusCode != 200) throw Exception(response.body);
    } catch (e) {
      print('Error sending WhatsApp message: $e');
    }
  }

  Stream<List<Payment>> getPendingPayments(String eventId) {
    return _firestore
        .collection('payments')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: PaymentStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Payment>> getPaymentsByStatus(
      String eventId, PaymentStatus status) {
    return _firestore
        .collection('payments')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: status.name)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> verifyPayment(String paymentId, bool approved) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User must be authenticated');

    await _firestore.collection('payments').doc(paymentId).update({
      'status':
          approved ? PaymentStatus.approved.name : PaymentStatus.rejected.name,
      'verifiedBy': userId,
      'verificationTime': FieldValue.serverTimestamp(),
    });
  }
}
