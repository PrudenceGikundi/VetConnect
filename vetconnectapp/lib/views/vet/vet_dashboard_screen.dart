import 'package:flutter/material.dart';

class VetDashboard extends StatelessWidget {
  const VetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinarian Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome to the Veterinarian Dashboard!'),
      ),
    );
  }
}