import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'vet_list_screen.dart'; // Import the VetListScreen

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  FarmerDashboardState createState() => FarmerDashboardState();
}

class FarmerDashboardState extends State<FarmerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _healthTips = [];
  bool _isLoading = true;

  int _currentIndex = 0; // Track the current index of the bottom navigation bar

  // Pages for the bottom navigation bar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchAppointments();
    _fetchHealthTips();

    // Initialize pages after fetching data
    _pages = [
      FarmerDashboardContent(
        appointments: _appointments,
        healthTips: _healthTips,
      ), // Home content
      const FarmerAppointmentsScreen(), // Appointments content
      const MessagesScreen(), // Messages content
      const SettingsScreen(), // Settings content
    ];
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _userName = userDoc['fullName'] ?? 'Farmer';
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
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
              'appointmentId': doc.id,
              'doctorName': data['doctorName'] ?? '',
              'appointmentType': data['appointmentType'] ?? '',
              'dateTime': (data['dateTime'] as Timestamp).toDate(),
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

  Future<void> _fetchHealthTips() async {
    try {
      final querySnapshot = await _firestore.collection('healthTips').get();
      setState(() {
        _healthTips = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      log('Error fetching health tips: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // Set AppBar background to white
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png', // Replace with your actual logo path
                  height: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  'Welcome, $_userName!', // Farmer's name
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black, // Set text color to black
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VetListScreen()),
                );
              },
              icon: const Icon(
                Icons.pets,
                color: Colors.white, // Icon color set to white
              ),
              label: const Text(
                'Book a Vet',
                style: TextStyle(
                  color: Colors.white, // Button text color set to white
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button background color remains green
                foregroundColor: Colors.white, // Ensure text and icon are white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex], // Display the current page based on the index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class FarmerDashboardContent extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final List<Map<String, dynamic>> healthTips;

  const FarmerDashboardContent({
    super.key,
    required this.appointments,
    required this.healthTips,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Find veterinarians by location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickActionButton(
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () {
                    // Navigate to messages screen
                  },
                ),
                _quickActionButton(
                  icon: Icons.warning,
                  label: 'Emergency Request',
                  onTap: () {
                    // Navigate to emergency request screen
                  },
                ),
                _quickActionButton(
                  icon: Icons.health_and_safety,
                  label: 'Health Tips',
                  onTap: () {
                    // Navigate to health tips screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Animal Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _animalFilterButton(label: 'Cow'),
                  _animalFilterButton(label: 'Sheep'),
                  _animalFilterButton(label: 'Goat'),
                  _animalFilterButton(label: 'Pig'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Appointments Section
            const Text(
              'Appointments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment['doctorName'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(appointment['appointmentType'] ?? ''),
                            const SizedBox(height: 5),
                            Text(appointment['dateTime']?.toString() ?? ''),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Health Tips Section
            const Text(
              'Health Tips & Articles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: healthTips.map((tip) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[50],
                      child: Icon(
                        _getIconFromString(tip['icon']),
                        color: Colors.teal,
                      ),
                    ),
                    title: Text(tip['title'] ?? ''),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Button
  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Animal Filter Button
  Widget _animalFilterButton({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () {
          // Filter by animal type
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[50],
          foregroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'pets':
        return Icons.pets;
      case 'grass':
        return Icons.grass;
      case 'egg':
        return Icons.egg;
      default:
        return Icons.info;
    }
  }
}

// Placeholder Widgets for Other Screens
class FarmerAppointmentsScreen extends StatelessWidget {
  const FarmerAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Appointments Screen'));
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Messages Screen'));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings Screen'));
  }
}