import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/vet_model.dart';
import '../models/farmer_model.dart';
import 'package:vetconnectapp/core/services/vet_service.dart';
import 'package:vetconnectapp/core/services/farmer_service.dart';
import 'package:vetconnectapp/core/services/firebase_auth_service.dart';
import 'package:vetconnectapp/core/services/booking_service.dart';
import '../models/appointment_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final VetService vetService;
  final FarmerService farmerService;
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final Logger _logger = Logger();
  
  // User type
  bool _isVet = false;
  bool get isVet => _isVet;
  
  // Current user data
  VetModel? _currentVet;
  FarmerModel? _currentFarmer;
  
  VetModel? get currentVet => _currentVet;
  FarmerModel? get currentFarmer => _currentFarmer;
  
  // Lists for the dashboard
  List<VetModel> _availableVets = [];
  List<VetModel> _nearbyVets = [];
  List<FarmerModel> _nearbyFarmers = [];
  List<AppointmentModel> _upcomingAppointments = [];
  
  List<VetModel> get availableVets => _availableVets;
  List<VetModel> get nearbyVets => _nearbyVets;
  List<FarmerModel> get nearbyFarmers => _nearbyFarmers;
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingVets = false;
  bool _isLoadingFarmers = false;
  bool _isLoadingAppointments = false;
  
  bool get isLoading => _isLoading;
  bool get isLoadingVets => _isLoadingVets;
  bool get isLoadingFarmers => _isLoadingFarmers;
  bool get isLoadingAppointments => _isLoadingAppointments;
  
  // Error states
  String? _error;
  String? get error => _error;
  
  // Constructor
  DashboardViewModel({
    required this.vetService,
    required this.farmerService,
  }) {
    initDashboard();
  }
  
  // Initialize dashboard data
  Future<void> initDashboard() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Determine if the current user is a vet or farmer
      await _determineUserType();
      
      // Load the appropriate data
      if (_isVet) {
        await Future.wait([
          _loadCurrentVet(),
          _loadNearbyFarmers(),
          _loadUpcomingAppointments()
        ]);
      } else {
        await Future.wait([
          _loadCurrentFarmer(),
          _loadAvailableVets(),
          _loadNearbyVets(),
          _loadUpcomingAppointments()
        ]);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      _logger.e(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Determine if the user is a vet or farmer
  Future<void> _determineUserType() async {
    try {
      final userType = await _authService.getUserType();
      _isVet = userType == 'vet';
    } catch (e) {
      _logger.e('Error determining user type: $e');
      _isVet = false; // Default to farmer if there's an error
    }
  }
  
  // Load current vet data
  Future<void> _loadCurrentVet() async {
    try {
      _currentVet = await vetService.getCurrentVet();
    } catch (e) {
      _logger.e('Error loading current vet: $e');
    }
  }
  
  // Load current farmer data
  Future<void> _loadCurrentFarmer() async {
    try {
      _currentFarmer = await farmerService.getCurrentFarmer();
    } catch (e) {
      _logger.e('Error loading current farmer: $e');
    }
  }
  
  // Load available vets (online and accepting appointments)
  Future<void> _loadAvailableVets() async {
    _isLoadingVets = true;
    notifyListeners();
    
    try {
      _availableVets = await vetService.getAvailableVets();
    } catch (e) {
      _logger.e('Error loading available vets: $e');
    } finally {
      _isLoadingVets = false;
      notifyListeners();
    }
  }
  
  // Load nearby vets based on location
  Future<void> _loadNearbyVets() async {
    if (_currentFarmer == null) return;
    
    _isLoadingVets = true;
    notifyListeners();
    
    try {
      _nearbyVets = await vetService.getVetsByLocation(_currentFarmer!.location);
    } catch (e) {
      _logger.e('Error loading nearby vets: $e');
    } finally {
      _isLoadingVets = false;
      notifyListeners();
    }
  }
  
  // Load nearby farmers based on location
  Future<void> _loadNearbyFarmers() async {
    if (_currentVet == null) return;
    
    _isLoadingFarmers = true;
    notifyListeners();
    
    try {
      _nearbyFarmers = await farmerService.getFarmersByLocation(_currentVet!.location);
    } catch (e) {
      _logger.e('Error loading nearby farmers: $e');
    } finally {
      _isLoadingFarmers = false;
      notifyListeners();
    }
  }
  
  // Load upcoming appointments
  Future<void> _loadUpcomingAppointments() async {
    _isLoadingAppointments = true;
    notifyListeners();
    
    try {
      _upcomingAppointments = await _bookingService.getUpcomingBookings();
    } catch (e) {
      _logger.e('Error loading upcoming appointments: $e');
    } finally {
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }
  
  // Search vets by name
  Future<List<VetModel>> searchVets(String query) async {
    if (query.isEmpty) return [];
    
    try {
      return await vetService.searchVetsByName(query);
    } catch (e) {
      _logger.e('Error searching vets: $e');
      return [];
    }
  }
  
  // Filter vets by specialization
  Future<List<VetModel>> filterVetsBySpecialization(String specialization) async {
    try {
      return await vetService.getVetsBySpecialization(specialization);
    } catch (e) {
      _logger.e('Error filtering vets: $e');
      return [];
    }
  }
  
  // Toggle vet availability (for vet users)
  Future<bool> toggleVetAvailability() async {
    if (_currentVet == null) return false;
    
    try {
      bool newAvailability = !(_currentVet!.isAvailable);
      
      await vetService.updateVetProfile({
        'isAvailable': newAvailability
      }, _currentVet!.id);
      
      // Update local state
      _currentVet = _currentVet!.copyWith(isAvailable: newAvailability);
      notifyListeners();
      
      return true;
    } catch (e) {
      _logger.e('Error toggling availability: $e');
      return false;
    }
  }
  
  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    return await initDashboard();
  }
}