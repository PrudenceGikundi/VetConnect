import 'package:flutter/material.dart';
import 'package:vetconnectapp/core/services/firebase_auth_service.dart';
import 'package:vetconnectapp/core/services/vet_service.dart';
import 'package:vetconnectapp/core/services/farmer_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService authService;
  final VetService vetService;
  final FarmerService farmerService;

  ProfileViewModel({
    required this.authService,
    required this.vetService,
    required this.farmerService,
  });

  // Your ProfileViewModel implementation
}