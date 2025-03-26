import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetconnectapp/models/appointment_model.dart';
import 'package:vetconnectapp/core/utils/app_constants.dart';
import 'package:logger/logger.dart';

class BookingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  final CollectionReference _appointmentsCollection = 
      FirebaseFirestore.instance.collection('appointments');

  // Create a new booking
  Future<String?> createBooking(AppointmentModel appointment) async {
    try {
      DocumentReference docRef = await _appointmentsCollection.add(appointment.toMap());

      // Update the appointment with the generated ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      _logger.e('Error creating booking: $e');
      return null;
    }
  }

  // Get available time slots for a specific vet on a specific date
  Future<List<String>> getAvailableTimeSlots(String vetId, DateTime date) async {
    try {
      // Convert date to start of day and end of day
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Get all appointments for the vet on the specified date
      QuerySnapshot snapshot = await _appointmentsCollection
          .where('vetId', isEqualTo: vetId)
          .where('scheduledDate', isGreaterThanOrEqualTo: startOfDay)
          .where('scheduledDate', isLessThanOrEqualTo: endOfDay)
          .get();

      // Extract the booked time slots
      List<String> bookedSlots = snapshot.docs.map((doc) {
        AppointmentModel appointment = AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
        return appointment.timeSlot;
      }).toList();

      // Create a list of all possible time slots (assuming 9 AM - 5 PM with 1-hour slots)
      List<String> allSlots = AppConstants.timeSlots;

      // Filter out the booked slots
      List<String> availableSlots = allSlots.where((slot) => !bookedSlots.contains(slot)).toList();

      return availableSlots;
    } catch (e) {
      _logger.e('Error getting available time slots: $e');
      return [];
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _appointmentsCollection.doc(bookingId).update({
        'status': status,
        'updatedAt': DateTime.now()
      });
      return true;
    } catch (e) {
      _logger.e('Error updating booking status: $e');
      return false;
    }
  }

  // Get booking details
  Future<AppointmentModel?> getBookingDetails(String bookingId) async {
    try {
      DocumentSnapshot doc = await _appointmentsCollection.doc(bookingId).get();

      if (doc.exists) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting booking details: $e');
      return null;
    }
  }

  // Get current user bookings
  Future<List<AppointmentModel>> getCurrentUserBookings() async {
    try {
      String uid = _auth.currentUser!.uid;

      // Get bookings where the current user is either the farmer or the vet
      QuerySnapshot farmerBookings = await _appointmentsCollection
          .where('farmerId', isEqualTo: uid)
          .orderBy('scheduledDate', descending: true)
          .get();

      QuerySnapshot vetBookings = await _appointmentsCollection
          .where('vetId', isEqualTo: uid)
          .orderBy('scheduledDate', descending: true)
          .get();

      List<AppointmentModel> bookings = [];

      // Add farmer bookings
      bookings.addAll(farmerBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Add vet bookings
      bookings.addAll(vetBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Sort by date (most recent first)
      bookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return bookings;
    } catch (e) {
      _logger.e('Error getting current user bookings: $e');
      return [];
    }
  }

  // Get upcoming bookings
  Future<List<AppointmentModel>> getUpcomingBookings() async {
    try {
      String uid = _auth.currentUser!.uid;
      DateTime now = DateTime.now();

      // Get bookings where the current user is either the farmer or the vet
      // and the scheduled date is after now
      QuerySnapshot farmerBookings = await _appointmentsCollection
          .where('farmerId', isEqualTo: uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: now)
          .orderBy('scheduledDate', descending: false)
          .get();

      QuerySnapshot vetBookings = await _appointmentsCollection
          .where('vetId', isEqualTo: uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: now)
          .orderBy('scheduledDate', descending: false)
          .get();

      List<AppointmentModel> bookings = [];

      // Add farmer bookings
      bookings.addAll(farmerBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Add vet bookings
      bookings.addAll(vetBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Sort by date (earliest first)
      bookings.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      return bookings;
    } catch (e) {
      _logger.e('Error getting upcoming bookings: $e');
      return [];
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _appointmentsCollection.doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now()
      });
      return true;
    } catch (e) {
      _logger.e('Error cancelling booking: $e');
      return false;
    }
  }

  // Get booking history
  Future<List<AppointmentModel>> getBookingHistory() async {
    try {
      String uid = _auth.currentUser!.uid;
      DateTime now = DateTime.now();

      // Get bookings where the current user is either the farmer or the vet
      // and the scheduled date is before now
      QuerySnapshot farmerBookings = await _appointmentsCollection
          .where('farmerId', isEqualTo: uid)
          .where('scheduledDate', isLessThan: now)
          .orderBy('scheduledDate', descending: true)
          .get();

      QuerySnapshot vetBookings = await _appointmentsCollection
          .where('vetId', isEqualTo: uid)
          .where('scheduledDate', isLessThan: now)
          .orderBy('scheduledDate', descending: true)
          .get();

      List<AppointmentModel> bookings = [];

      // Add farmer bookings
      bookings.addAll(farmerBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Add vet bookings
      bookings.addAll(vetBookings.docs.map((doc) {
        return AppointmentModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }));

      // Sort by date (most recent first)
      bookings.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      return bookings;
    } catch (e) {
      _logger.e('Error getting booking history: $e');
      return [];
    }
  }

  Future<List<AppointmentModel>> getPastBookings() async {
    QuerySnapshot snapshot = await _firestore
        .collection('appointments')
        .where('scheduledDate', isLessThan: DateTime.now())
        .orderBy('scheduledDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}