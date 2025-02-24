import 'package:flutter/material.dart';
import 'package:stockflow/services/auth_state_manager.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/screens/login_page.dart';
import 'package:stockflow/views/screens/signup_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Add a small delay to show splash screen
    await Future.delayed(Duration(seconds: 2));

    final isFirstTime = await AuthStateManager.isFirstTimeUser();
    final isLoggedIn = await AuthStateManager.isLoggedIn();

    if (mounted) {
      if (isFirstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      } else if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
