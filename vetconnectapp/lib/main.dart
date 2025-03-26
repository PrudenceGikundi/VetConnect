import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vetconnectapp/views/splash/splash_screen.dart';
import 'package:vetconnectapp/views/onboarding/onboarding_screen.dart';
import 'package:vetconnectapp/views/auth/signup_screen.dart';
import 'package:vetconnectapp/views/auth/login_screen.dart';
import 'package:vetconnectapp/views/farmer/farmer_dashboard_screen.dart';
import 'package:vetconnectapp/views/vet/vet_dashboard_screen.dart';
import 'package:vetconnectapp/providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        title: 'VetConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.teal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            primary: Colors.teal,
            secondary: Colors.orange,
          ),
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding_screen': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/farmer_dashboard': (context) => const FarmerDashboard(),
          '/vet_dashboard': (context) => const VetDashboard(),
        },
      ),
    );
  }
}
