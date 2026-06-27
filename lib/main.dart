import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/company_repository.dart';
import 'data/repositories/service_repository.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/booking_viewmodel.dart';
import 'presentation/viewmodels/customer_home_viewmodel.dart';
import 'presentation/viewmodels/seller_home_viewmodel.dart';
import 'presentation/viewmodels/service_viewmodel.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ldoljthtmrpsveavjcdb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxkb2xqdGh0bXJwc3ZlYXZqY2RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NDk4MjYsImV4cCI6MjA5ODEyNTgyNn0.77i3E2ECtQa7-N2ZKpBOxk4DkAy6VLHUcynFuOokGIA',
  );

  final authRepository = AuthRepository();
  final companyRepository = CompanyRepository();
  final serviceRepository = ServiceRepository();
  final bookingRepository = BookingRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerHomeViewModel(
            companyRepository: companyRepository,
            serviceRepository: serviceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SellerHomeViewModel(
            bookingRepository: bookingRepository,
            companyRepository: companyRepository,
            serviceRepository: serviceRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingViewModel(bookingRepository: bookingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceViewModel(serviceRepository: serviceRepository),
        ),
      ],
      child: const FixEasyApp(),
    ),
  );
}
