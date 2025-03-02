import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/services/auth_state_manager.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/screens/login_Page.dart';
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

  Future _checkAuthState() async {
    await Future.delayed(Duration(seconds: 2));

    // Check both Firebase and SharedPreferences
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isLoggedInFirebase = firebaseUser != null;

    final isFirstTime = await AuthStateManager.isFirstTimeUser();
    final isLoggedInPrefs = await AuthStateManager.isLoggedIn();

    print(
        "Debug - Firebase logged in: $isLoggedInFirebase, SharedPrefs logged in: $isLoggedInPrefs");

    // If there's a mismatch, sync them
    if (isLoggedInFirebase != isLoggedInPrefs) {
      if (isLoggedInFirebase) {
        await AuthStateManager.setLoggedIn();
      } else {
        await AuthStateManager.setLoggedOut();
      }
    }

    // Use Firebase auth as the source of truth
    if (mounted) {
      if (isFirstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );
      } else if (isLoggedInFirebase) {
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
