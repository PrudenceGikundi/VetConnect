import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import './core/services/firebase_auth_service.dart';
import './core/services/booking_service.dart';
import './core/services/chat_service.dart';
import './core/services/farmer_service.dart';
import './core/services/vet_service.dart';
import './view_models/auth_viewmodel.dart';
import './view_models/booking_viewmodel.dart';
import 'package:vetconnectapp/view_models/chat_viewmodel.dart';
import 'package:vetconnectapp/view_models/dashboard_viewmodel.dart';
import 'package:vetconnectapp/view_models/farmer_viewmodel.dart';
import 'package:vetconnectapp/view_models/profile_viewmodel.dart';

List<SingleChildWidget> appProviders = [
  // Services
  ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
  Provider<VetService>(
    create: (_) => VetService(),
  ),
  Provider<FarmerService>(
    create: (_) => FarmerService(),
  ),
  Provider<BookingService>(
    create: (_) => BookingService(),
  ),
  Provider<ChatService>(
    create: (_) => ChatService(),
  ),
  
  // ViewModels
  ChangeNotifierProvider<AuthViewModel>(
    create: (context) => AuthViewModel(
      authService: context.read<AuthService>(),
    ),
  ),
  ChangeNotifierProvider<DashboardViewModel>(
    create: (context) => DashboardViewModel(
      vetService: context.read<VetService>(),
      farmerService: context.read<FarmerService>(),
    ),
  ),
  ChangeNotifierProvider<BookingViewModel>(
    create: (context) => BookingViewModel(
      bookingService: context.read<BookingService>(),
    ),
  ),
  ChangeNotifierProvider<ChatViewModel>(
    create: (context) => ChatViewModel(
      chatService: context.read<ChatService>(),
    ),
  ),
  ChangeNotifierProvider<ProfileViewModel>(
    create: (context) => ProfileViewModel(
      authService: context.read<AuthService>(),
      vetService: context.read<VetService>(),
      farmerService: context.read<FarmerService>(),
    ),
  ),
  ChangeNotifierProvider<FarmerViewModel>(
    create: (context) => FarmerViewModel(
      context.read<FarmerService>(),
    ),
  ),
];