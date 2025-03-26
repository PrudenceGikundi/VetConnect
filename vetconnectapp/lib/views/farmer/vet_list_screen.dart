import 'package:flutter/material.dart';

class VetListScreen extends StatelessWidget {
  const VetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> vets = [
      {'name': 'Dr. Alaric Voss', 'specialization': 'Large Animals'},
      {'name': 'Dr. Beatrix Lin', 'specialization': 'Small Animals'},
      {'name': 'Dr. Cillian Faulkner', 'specialization': 'Poultry'},
      {'name': 'Dr. Dalia Marquez', 'specialization': 'Dairy Cattle'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Vet'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: vets.length,
        itemBuilder: (context, index) {
          final vet = vets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(vet['name'] ?? ''),
              subtitle: Text(vet['specialization'] ?? ''),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to vet booking screen or perform booking logic
                  Navigator.pop(context); // Example: Go back after selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Book'),
              ),
            ),
          );
        },
      ),
    );
  }
}