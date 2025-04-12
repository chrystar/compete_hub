import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/news.dart';

class NewsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createNews({
    required String title,
    required String description,
    required String eventId,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Must be logged in to post news');

    await _firestore.collection('news').add({
      'title': title,
      'description': description,
      'eventId': eventId,
      'organizerId': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    });
  }

  Stream<List<News>> getEventNews(String eventId) {
    return _firestore
        .collection('news')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => News.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<News>> streamNews() {
    return _firestore
        .collection('news')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => News.fromJson(doc.data(), doc.id)).toList());
  }
}
