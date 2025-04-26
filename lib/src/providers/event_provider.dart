import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compete_hub/src/models/announcement.dart';
import 'package:compete_hub/src/models/chat_message.dart';
import 'package:compete_hub/src/models/event.dart';
import 'package:compete_hub/src/models/event_category.dart' as event_category;
import 'package:compete_hub/src/models/match.dart'; // Add this import
import 'package:compete_hub/src/models/participant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/registration.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Add a currentUser getter
  User? get currentUser => _currentUser;

  User? _currentUser;

  // Add a method to set the current user
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Add authentication check helper
  void _checkAuth() {
    if (_auth.currentUser == null) {
      throw Exception('User must be authenticated to perform this action');
    }
  }

  bool isEventOrganizer(String eventOrganizerId) {
    return _auth.currentUser?.uid == eventOrganizerId;
  }

  Future<String> createEvent(Event event) async {
    try {
      _checkAuth(); // Add auth check
      _isLoading = true;
      _error = null;
      notifyListeners();

      final docRef = await _firestore.collection('events').add(event.toJson());
      _isLoading = false;
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<Event>> getEvents({bool publicOnly = true}) async {
    try {
      _checkAuth(); // Add auth check
      _isLoading = true;
      notifyListeners();

      Query<Map<String, dynamic>> query = _firestore.collection('events');
      if (publicOnly) {
        query = query.where('visibility',
            isEqualTo: EventVisibility.public.toString());
      }

      final snapshot = await query.get();
      _isLoading = false;
      notifyListeners();

      return snapshot.docs
          .map((doc) => Event.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to fetch events: $e');
    }
  }

  Stream<List<Event>> getUserEvents(String userId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateEvent(Event event) async {
    try {
      _checkAuth(); // Add auth check
      // Verify the user owns this event
      final doc = await _firestore.collection('events').doc(event.id).get();
      if (doc.data()?['organizerId'] != _auth.currentUser?.uid) {
        throw Exception('Can only update events you created');
      }
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection('events')
          .doc(event.id)
          .update(event.toJson());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      _checkAuth(); // Add auth check
      // Verify the user owns this event
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.data()?['organizerId'] != _auth.currentUser?.uid) {
        throw Exception('Can only delete events you created');
      }
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('events').doc(eventId).delete();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to delete event: $e');
    }
  }

  Stream<List<Event>> streamEvents({bool publicOnly = true}) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated to stream events');
    }
    Query<Map<String, dynamic>> query = _firestore.collection('events');
    if (publicOnly) {
      query = query.where('visibility',
          isEqualTo: EventVisibility.public.toString());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Event>> streamEventsByCategory(
      event_category.EventCategory? category) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated to stream events');
    }

    Query<Map<String, dynamic>> query = _firestore.collection('events');

    if (category != null) {
      // Use the correct string format for category comparison
      query =
          query.where('category', isEqualTo: 'EventCategory.${category.name}');
    }

    return query.snapshots().map((snapshot) {
      print('Found ${snapshot.docs.length} events'); // Debug print
      return snapshot.docs.map((doc) {
        print('Event category: ${doc.data()['category']}'); // Debug print
        return Event.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Map<String, dynamic>> registerForEvent(
    String eventId, {
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String location,
  }) async {
    try {
      _checkAuth();
      final userId = _auth.currentUser!.uid;

      // Check if already registered
      final existing = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Already registered for this event');
      }

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final event = Event.fromJson(eventDoc.data()!, eventDoc.id);

      final registration = Registration(
        id: '',
        eventId: eventId,
        fullName: fullName,
        email: email,
        phone: phone,
        gender: gender,
        location: location,
        userId: userId,
        registrationDate: DateTime.now(),
        paymentStatus: event.feeType == EventFeeType.free
            ? PaymentStatus.approved
            : PaymentStatus.pending,
      );

      final regRef = await _firestore
          .collection('registrations')
          .add(registration.toMap());

      return {
        'registrationId': regRef.id,
        'feeType': event.feeType,
        'amount': event.entryFee,
      };
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  Stream<List<String>> streamRegisteredEventIds() {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('event_registrations')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['eventId'] as String).toList());
  }

  Future<bool> isRegisteredForEvent(String eventId) async {
    try {
      _checkAuth();
      final userId = _auth.currentUser!.uid;

      final snapshot = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Stream<bool> isRegisteredForEventStream(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return false;

      // Check registration status
      final registration = snapshot.docs.first.data();
      final status = registration['paymentStatus'] ?? 'pending';
      return status == 'approved' || status == 'pending';
    });
  }

  Stream<List<Event>> getPopularEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .asyncMap((snapshot) async {
      final events = await Future.wait(snapshot.docs.map((doc) async {
        final event = Event.fromJson(doc.data(), doc.id);
        final likesSnapshot = await _firestore
            .collection('events')
            .doc(doc.id)
            .collection('likes')
            .get();
        final likesCount = likesSnapshot.docs.length;

        return MapEntry(event, likesCount);
      }));

      // Filter events with likes >= 1 and sort by likes count
      final popularEvents = events
          .where((entry) => entry.value >= 1)
          .map((entry) => entry.key)
          .toList()
        ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

      return popularEvents;
    });
  }

  Stream<List<Event>> getTodayEvents() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('events')
        .where('startDateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('startDateTime', isLessThan: endOfDay)
        .where('visibility', isEqualTo: EventVisibility.public.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Event>> searchEvents(String query) {
    return _firestore
        .collection('events')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .where('visibility', isEqualTo: EventVisibility.public.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Match>> getEventMatches(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('matches')
        .where('eventId', isEqualTo: eventId)
        .orderBy('round')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Match.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> generateBrackets(String eventId) async {
    try {
      _checkAuth();

      // Get participants
      final participants = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .get();

      // Create matches for first round
      final playerIds = participants.docs.map((doc) => doc.id).toList();
      for (var i = 0; i < playerIds.length; i += 2) {
        if (i + 1 < playerIds.length) {
          await _firestore.collection('matches').add({
            'eventId': eventId,
            'round': 1,
            'player1': playerIds[i],
            'player2': playerIds[i + 1],
            'scheduledTime': null,
            'scores': null,
            'winnerId': null,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to generate brackets: $e');
    }
  }

  Stream<List<Announcement>> getAnnouncements(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('announcements')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> createAnnouncement(String eventId, String message) async {
    try {
      _checkAuth();
      final userId = _auth.currentUser!.uid;

      await _firestore.collection('announcements').add({
        'eventId': eventId,
        'message': message,
        'senderId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  Stream<List<ChatMessage>> getLiveChat(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('chat_messages')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to last 100 messages
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendChatMessage(String eventId, String message) async {
    try {
      _checkAuth();
      final user = _auth.currentUser!;

      await _firestore.collection('chat_messages').add({
        'eventId': eventId,
        'senderId': user.uid,
        'senderName': user.email ?? 'Anonymous',
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<Participant>> getParticipants(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Participant.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateParticipantStatus(
      String participantId, ParticipantStatus newStatus) async {
    try {
      _checkAuth();
      await _firestore
          .collection('registrations')
          .doc(participantId)
          .update({'status': newStatus.toString()});
    } catch (e) {
      throw Exception('Failed to update participant status: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getLeaderboard(String eventId) {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('matches')
        .where('eventId', isEqualTo: eventId)
        .where('winnerId', isNull: false)
        .snapshots()
        .map((snapshot) {
      // Calculate points for each player
      final Map<String, int> playerPoints = {};
      final Map<String, String> playerNames = {};

      for (var doc in snapshot.docs) {
        final match = Match.fromJson(doc.data(), doc.id);
        if (match.winnerId != null) {
          playerPoints[match.winnerId!] =
              (playerPoints[match.winnerId!] ?? 0) + 1;
          // Store player names from match data
          playerNames[match.player1] = match.player1;
          playerNames[match.player2] = match.player2;
        }
      }

      // Convert to list and sort by points
      final standings = playerNames.keys.map((playerId) {
        return {
          'id': playerId,
          'name': playerNames[playerId] ?? 'Unknown',
          'points': playerPoints[playerId] ?? 0,
        };
      }).toList();

      standings.sort((a, b) => ((b as Map<String, dynamic>)['points'] ?? 0)
          .compareTo((a as Map<String, dynamic>)['points'] ?? 0));
      return standings;
    });
  }

  Stream<List<Announcement>> getMyNotifications() {
    if (_auth.currentUser == null) {
      return Stream.error('User must be authenticated');
    }

    return _firestore
        .collection('announcements')
        .where('recipients', arrayContains: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      _checkAuth();
      await _firestore.collection('announcements').doc(notificationId).update({
        'readBy': FieldValue.arrayUnion([_auth.currentUser!.uid])
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Stream<List<Registration>> getEventRegistrations(String eventId) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Registration.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Registration>> getRegistrationsByStatus(
      String eventId, PaymentStatus status) {
    print(
        'Querying registrations - Event: $eventId, Status: ${status.toString()}');

    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('paymentStatus', isEqualTo: status.toString())
        .snapshots()
        .map((snapshot) {
      final registrations = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Raw registration data: $data'); // Debug print
        final registration = Registration.fromJson(data, doc.id);
        print(
            'Parsed registration: ${registration.fullName}, Status: ${registration.paymentStatus}');
        return registration;
      }).toList();

      print('Total registrations found: ${registrations.length}');
      return registrations;
    });
  }

  Future<void> updateRegistrationStatus(
      String registrationId, PaymentStatus newStatus) async {
    try {
      _checkAuth();
      await _firestore.collection('registrations').doc(registrationId).update({
        'paymentStatus': newStatus.toString(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser!.uid,
      });
    } catch (e) {
      throw Exception('Failed to update registration status: $e');
    }
  }

  Stream<List<Registration>> getApprovedPaidRegistrations(String eventId) {
    return _firestore
        .collection('registrations')
        .where('eventId', isEqualTo: eventId)
        .where('paymentStatus', isEqualTo: PaymentStatus.approved.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Registration.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get reference to likes collection for an event
  CollectionReference _getLikesCollection(String eventId) {
    return _firestore.collection('events').doc(eventId).collection('likes');
  }

  // Stream of likes count for an event
  Stream<int> getEventLikes(String eventId) {
    return _getLikesCollection(eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Check if current user has liked the event
  Future<bool> hasUserLikedEvent(String eventId) async {
    if (_auth.currentUser == null) return false;

    final doc =
        await _getLikesCollection(eventId).doc(_auth.currentUser!.uid).get();
    return doc.exists;
  }

  // Toggle like status for current user
  Future<void> toggleEventLike(String eventId) async {
    if (_auth.currentUser == null) return;

    final userLikeRef =
        _getLikesCollection(eventId).doc(_auth.currentUser!.uid);
    final userLikeDoc = await userLikeRef.get();

    if (userLikeDoc.exists) {
      await userLikeRef.delete();
    } else {
      await userLikeRef.set({
        'userId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    notifyListeners();
  }

  Future<String> uploadEventBanner(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('event_banners').child(fileName);

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading banner image: $e');
      throw Exception('Failed to upload banner image');
    }
  }

  Stream<int> getUserEventsCount(String userId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getUserRegistrationsCount(String userId) {
    return _firestore
        .collection('events')
        .snapshots()
        .asyncMap((snapshot) async {
      int count = 0;
      for (var doc in snapshot.docs) {
        final registrations = await doc.reference
            .collection('registrations')
            .where('userId', isEqualTo: userId)
            .get();
        if (registrations.docs.isNotEmpty) count++;
      }
      return count;
    });
  }
} // End of class
