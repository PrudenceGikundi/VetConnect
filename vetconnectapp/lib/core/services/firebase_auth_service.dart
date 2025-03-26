import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetconnectapp/core/utils/app_constants.dart';
import 'package:vetconnectapp/models/user_model.dart';
import 'package:vetconnectapp/models/vet_model.dart';
import 'package:vetconnectapp/models/farmer_model.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String> getUserType() async {
    // Implementation to get user type (vet or farmer)
    // This is just a placeholder implementation
    return 'vet'; // or 'farmer'
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Create vet document in Firestore
  Future<void> createVetDocument(VetModel vet) async {
    try {
      await _firestore.collection(AppConstants.vetsCollection).doc(vet.id).set(vet.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Create farmer document in Firestore
  Future<void> createFarmerDocument(FarmerModel farmer) async {
    try {
      await _firestore.collection(AppConstants.farmersCollection).doc(farmer.id).set(farmer.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get user document from Firestore
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is a vet
  Future<bool> isUserVet(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.vetsCollection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is a farmer
  Future<bool> isUserFarmer(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.farmersCollection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(user.id).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }
}