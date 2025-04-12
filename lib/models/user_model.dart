class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String? displayName;
  final String? phoneNumber;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.displayName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json) {

    return UserProfile(
      uid: json['uid'] ?? '', // Provide a default value if null
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
