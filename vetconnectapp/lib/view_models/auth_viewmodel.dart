import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetconnectapp/core/services/firebase_auth_service.dart';
import 'package:vetconnectapp/models/user_model.dart';
import 'package:vetconnectapp/models/vet_model.dart';
import 'package:vetconnectapp/models/farmer_model.dart';

enum AuthStatus { initial, authenticating, authenticated, error, unauthenticated }
enum UserType { vet, farmer }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isVet = false;
  bool _isFarmer = false;

  AuthViewModel({required AuthService authService}) : _authService = authService {
    _checkCurrentUser();
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isVet => _isVet;
  bool get isFarmer => _isFarmer;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Check current user on startup
  Future<void> _checkCurrentUser() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    final user = _authService.currentUser;
    if (user != null) {
      try {
        final userDoc = await _authService.getUserDocument(user.uid);
        if (userDoc != null) {
          _user = userDoc;
          await _checkUserType(user.uid);
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = e.toString();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Check if user is vet or farmer
  Future<void> _checkUserType(String uid) async {
    try {
      _isVet = await _authService.isUserVet(uid);
      _isFarmer = await _authService.isUserFarmer(uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithEmailAndPassword(email, password);
      final userDoc = await _authService.getUserDocument(result.user!.uid);
      
      if (userDoc != null) {
        _user = userDoc;
        await _checkUserType(result.user!.uid);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'User not found';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register as a vet or farmer
  Future<bool> register({
    required String email, 
    required String password, 
    required String name, 
    required String phone, 
    required UserType userType,
    String? specialization,
    String? experience,
    String? location,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.registerWithEmailAndPassword(email, password);
      final uid = result.user!.uid;
      
      // Create base user
      final user = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      
      // Create user document
      await _authService.createUserDocument(user);
      
      // Create specific user type document (vet or farmer)
      if (userType == UserType.vet) {
        final vet = VetModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          specializations: [specialization ?? 'General'],
          experience: experience ?? '0',
          location: location ?? '',
          rating: 0.0,
          reviewCount: 0,
          isAvailable: true,
          createdAt: DateTime.now(),
        );
        await _authService.createVetDocument(vet);
        _isVet = true;
      } else {
        final farmer = FarmerModel(
          id: uid,
          name: name,
          email: email,
          phone: phone,
          location: location ?? '',
          createdAt: DateTime.now(),
        );
        await _authService.createFarmerDocument(farmer);
        _isFarmer = true;
      }
      
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _isVet = false;
      _isFarmer = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      notifyListeners();
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get error message from Firebase exceptions
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}