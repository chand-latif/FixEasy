import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fix_easy/customer_screens/customer_home.dart';
import 'package:fix_easy/seller_screens/create_company_profile.dart';
import 'theme.dart';
import 'dart:async';
import 'data/repositories/auth_repository.dart';

class StartupScreen extends StatefulWidget {
  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    Future.delayed(Duration.zero, () async {
      await _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    try {
      final user = await AuthRepository().getUserInfo();
      if (!mounted) return;

      if (user.isCustomer) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CustomerHome()),
        );
      } else if (user.isSeller) {
        if (!user.isCompanyProfileExist) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCompanyProfileScreen(),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/sellerHome');
        }
      }
    } catch (e) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/FixEasy.png', width: 220),
              SizedBox(height: 40),
              Text(
                'Your Home Service Partner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
