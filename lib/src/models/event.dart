import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_category.dart' as event_category;

enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin,
  swissSystem
}

enum EventVisibility { public, private }

enum EventLocationType { online, offline }

enum EventFeeType { free, paid }

class RegisteredUser {
  final String id;
  final String name;
  final String? photoUrl;

  RegisteredUser({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }
}

class Event {
  final String id;
  final String name;
  final event_category.EventCategory category;
  final String description;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final EventLocationType locationType;
  final String? location;
  final String organizerInfo;
  final TournamentFormat format;
  final int maxParticipants;
  final EventFeeType feeType;
  final double? entryFee;
  final DateTime entryDeadline;
  final String? eligibilityRules;
  final EventVisibility visibility;
  final String organizerId;
  final List<RegisteredUser>? registeredUsers;
  final String organizerWhatsApp;
  final String organizerEmail;
  final String bankDetails;
  final String? bannerImageUrl;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.locationType,
    this.location,
    required this.organizerInfo,
    required this.format,
    required this.maxParticipants,
    required this.feeType,
    this.entryFee,
    required this.entryDeadline,
    this.eligibilityRules,
    required this.visibility,
    required this.organizerId,
    this.registeredUsers,
    required this.organizerWhatsApp,
    required this.organizerEmail,
    required this.bankDetails,
    this.bannerImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category.name, // Store just the name
      'description': description,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'locationType': locationType.toString(),
      'location': location,
      'organizerInfo': organizerInfo,
      'format': format.toString(),
      'maxParticipants': maxParticipants,
      'feeType': feeType.toString(),
      'entryFee': entryFee,
      'entryDeadline': Timestamp.fromDate(entryDeadline),
      'eligibilityRules': eligibilityRules,
      'visibility': visibility.toString(),
      'organizerId': organizerId,
      'createdAt': Timestamp.now(),
      'registeredUsers': registeredUsers
          ?.map((u) => {
                'id': u.id,
                'name': u.name,
                'photoUrl': u.photoUrl,
              })
          .toList(),
      'organizerWhatsApp': organizerWhatsApp,
      'organizerEmail': organizerEmail,
      'bankDetails': bankDetails,
      'bannerImageUrl': bannerImageUrl,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json, String id) {
    return Event(
      id: id,
      name: json['name'],
      category: event_category.EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => event_category.EventCategory.games,
      ),
      description: json['description'],
      startDateTime: (json['startDateTime'] as Timestamp).toDate(),
      endDateTime: (json['endDateTime'] as Timestamp).toDate(),
      locationType: EventLocationType.values
          .firstWhere((e) => e.toString() == json['locationType']),
      location: json['location'],
      organizerInfo: json['organizerInfo'],
      format: TournamentFormat.values
          .firstWhere((e) => e.toString() == json['format']),
      maxParticipants: json['maxParticipants'],
      feeType: EventFeeType.values
          .firstWhere((e) => e.toString() == json['feeType']),
      entryFee: json['entryFee'],
      entryDeadline: (json['entryDeadline'] as Timestamp).toDate(),
      eligibilityRules: json['eligibilityRules'],
      visibility: EventVisibility.values
          .firstWhere((e) => e.toString() == json['visibility']),
      organizerId: json['organizerId'],
      registeredUsers: (json['registeredUsers'] as List<dynamic>?)
          ?.map((u) => RegisteredUser.fromJson(u))
          .toList(),
      organizerWhatsApp: json['organizerWhatsApp'] ?? '',
      organizerEmail: json['organizerEmail'] ?? '',
      bankDetails: json['bankDetails'] ?? '',
      bannerImageUrl: json['bannerImageUrl'] as String?,
    );
  }
}
