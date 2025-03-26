import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'VetConnect';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Get Veterinary Help Anytime, Anywhere!';
  
  // API Endpoints
  static const String baseUrl = 'https://api.vetconnect.com';
  
  // Storage Keys
  static const String userPrefsKey = 'user_prefs';
  static const String authTokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  
  // Collections
  static const String usersCollection = 'users';
  static const String vetsCollection = 'vets';
  static const String farmersCollection = 'farmers';
  static const String appointmentsCollection = 'appointments';
  static const String messagesCollection = 'messages';
  
  // Navigation Routes
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String vetDashboardRoute = '/vet/dashboard';
  static const String farmerDashboardRoute = '/farmer/dashboard';

  // Time Slots
  static const List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];
}

class AppColors {
  static const Color primaryColor = Color(0xFF008080); // Teal
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF333333);
  static const Color lightTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color errorColor = Color(0xFFD32F2F);
}

class AppAssets {
  static const String logoPath = 'assets/images/logo.png';
  static const String splashBgPath = 'assets/images/splash_bg.png';
  static const String vetProfileImagePath = 'assets/images/vet_profile.png';
  static const String farmerProfileImagePath = 'assets/images/farmer_profile.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
}