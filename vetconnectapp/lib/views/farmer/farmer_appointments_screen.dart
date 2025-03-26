import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class FarmerAppointmentsScreen extends StatefulWidget {
  const FarmerAppointmentsScreen({super.key});

  @override
  FarmerAppointmentsScreenState createState() => FarmerAppointmentsScreenState();
}

class FarmerAppointmentsScreenState extends State<FarmerAppointmentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> createAppointment(String vetId, String doctorName, String appointmentType, DateTime dateTime) async {
    try {
      final String userId = _auth.currentUser!.uid; // Get the current user's ID
      final String appointmentId = _firestore.collection('appointments').doc().id; // Generate unique ID

      await _firestore.collection('appointments').doc(appointmentId).set({
        'appointmentId': appointmentId,
        'userId': userId,
        'vetId': vetId,
        'doctorName': doctorName,
        'appointmentType': appointmentType,
        'dateTime': Timestamp.fromDate(dateTime), // Convert DateTime to Firestore Timestamp
      });

      log('Appointment created successfully');
    } catch (e) {
      log('Error creating appointment: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .get();
        setState(() {
          _appointments = querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'appointmentId': doc.id, // Use Firestore document ID
              'doctorName': data['doctorName'] ?? '',
              'appointmentType': data['appointmentType'] ?? '',
              'dateTime': (data['dateTime'] as Timestamp).toDate(), // Convert Timestamp to DateTime
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching appointments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: _appointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No appointments found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            title: Text(
                              appointment['doctorName'] ?? 'Unknown Doctor',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appointment['appointmentType'] ?? 'Unknown Type'),
                                Text(appointment['dateTime']?.toString() ?? 'Unknown Date'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Navigate to appointment details (if needed)
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FarmerAppointmentsScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Book a Vet'),
      ),
    );
  }
}