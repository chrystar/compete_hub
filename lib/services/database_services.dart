import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Asynchronous function to create a user profile in Firestore
  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      // Add a new document to the 'users' collection using the user's UID as the document ID
      await _firestore.collection('users').doc(userProfile.uid).set(
          userProfile.toJson()); // Use toJson() to convert UserProfile to Map
    } catch (e) {
      // Handle any errors that occur during the Firestore operation
      print("Error creating user profile in Firestore: $e"); // Log the error
      rethrow; // Re-throw the error to be handled by the caller
    }
  }
//You can add more database related functions here
}
