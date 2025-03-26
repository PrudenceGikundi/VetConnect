import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/appointment_model.dart';
import '../models/vet_model.dart';
import 'package:vetconnectapp/core/services/booking_service.dart';
import 'package:vetconnectapp/core/services/farmer_service.dart';
import 'package:vetconnectapp/core/services/firebase_auth_service.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService bookingService;
  final Logger _logger = Logger();

  BookingViewModel({
    required this.bookingService,
  });

  final FarmerService _farmerService = FarmerService();
  final AuthService _authService = AuthService();
  
  // Selected vet and date
  VetModel? _selectedVet;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _animalType = '';
  String _reason = '';
  bool _isEmergency = false;
  
  // Available time slots
  List<String> _availableTimeSlots = [];
  
  // Loading and error states
  bool _isLoading = false;
  bool _isLoadingTimeSlots = false;
  String? _error;
  
  // Appointments
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _pastAppointments = [];
  AppointmentModel? _currentAppointment;
  
  // Getters
  VetModel? get selectedVet => _selectedVet;
  DateTime get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  String get animalType => _animalType;
  String get reason => _reason;
  bool get isEmergency => _isEmergency;
  List<String> get availableTimeSlots => _availableTimeSlots;
  bool get isLoading => _isLoading;
  bool get isLoadingTimeSlots => _isLoadingTimeSlots;
  String? get error => _error;
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  List<AppointmentModel> get pastAppointments => _pastAppointments;
  AppointmentModel? get currentAppointment => _currentAppointment;
  
  // Select a vet
  void selectVet(VetModel vet) {
    _selectedVet = vet;
    loadAvailableTimeSlots();
    notifyListeners();
  }
  
  // Select a date
  void selectDate(DateTime date) {
    _selectedDate = date;
    loadAvailableTimeSlots();
    notifyListeners();
  }
  
  // Select a time slot
  void selectTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }
  
  // Set animal type
  void setAnimalType(String animalType) {
    _animalType = animalType;
    notifyListeners();
  }
  
  // Set reason
  void setReason(String reason) {
    _reason = reason;
    notifyListeners();
  }
  
  // Set emergency status
  void setEmergency(bool isEmergency) {
    _isEmergency = isEmergency;
    notifyListeners();
  }
  
  // Load available time slots
  Future<void> loadAvailableTimeSlots() async {
    if (_selectedVet == null) return;
    
    _isLoadingTimeSlots = true;
    _availableTimeSlots = [];
    notifyListeners();
    
    try {
      _availableTimeSlots = await bookingService.getAvailableTimeSlots(
        _selectedVet!.id, 
        _selectedDate
      );
      
      // Clear selected time slot if it's no longer available
      if (_selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot)) {
        _selectedTimeSlot = null;
      }
    } catch (e) {
      _error = 'Error loading available time slots: $e';
      _logger.e(_error);
    } finally {
      _isLoadingTimeSlots = false;
      notifyListeners();
    }
  }
  
  // Check if booking is valid
  bool isBookingValid() {
    return _selectedVet != null && 
           _selectedTimeSlot != null && 
           _animalType.isNotEmpty && 
           _reason.isNotEmpty;
  }
  
  // Create a booking
  Future<String?> createBooking() async {
    if (!isBookingValid()) return null;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get current user (farmer) data
      final currentUser = await _authService.getCurrentUser();
      final farmer = await _farmerService.getCurrentFarmer();
      
      if (currentUser == null || farmer == null) {
        _error = 'Failed to get user data';
        return null;
      }
      
      // Create appointment model
      final appointment = AppointmentModel(
        id: '',
        vetId: _selectedVet!.id,
        farmerId: farmer.id,
        vetName: _selectedVet!.name,
        farmerName: farmer.name,
        scheduledDate: _selectedDate,
        timeSlot: _selectedTimeSlot!,
        status: 'pending',
        animalType: _animalType,
        reason: _reason,
        isEmergency: _isEmergency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: '',
        durationMinutes: 60 // Default to 1 hour
      );
      
      // Create booking in Firestore
      final bookingId = await bookingService.createBooking(appointment);
      
      if (bookingId != null) {
        // Add to upcoming appointments
        _upcomingAppointments.add(appointment.copyWith(id: bookingId));
        _upcomingAppointments.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
        
        // Reset form
        resetForm();
        notifyListeners();
      }
      
      return bookingId;
    } catch (e) {
      _error = 'Failed to create booking: $e';
      _logger.e(_error);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset booking form
  void resetForm() {
    _selectedVet = null;
    _selectedDate = DateTime.now();
    _selectedTimeSlot = null;
    _animalType = '';
    _reason = '';
    _isEmergency = false;
    _availableTimeSlots = [];
  }
  
  // Load appointments
  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load upcoming and past appointments
      await Future.wait([
        _loadUpcomingAppointments(),
        _loadPastAppointments()
      ]);
    } catch (e) {
      _error = 'Failed to load appointments: $e';
      _logger.e(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load upcoming appointments
  Future<void> _loadUpcomingAppointments() async {
    try {
      _upcomingAppointments = await bookingService.getUpcomingBookings();
    } catch (e) {
      _error = 'Error loading upcoming appointments: $e';
      _logger.e(_error);
    }
  }

  // Load past appointments
  Future<void> _loadPastAppointments() async {
    try {
      _pastAppointments = await bookingService.getPastBookings();
    } catch (e) {
      _error = 'Error loading past appointments: $e';
      _logger.e(_error);
    }
  }
}