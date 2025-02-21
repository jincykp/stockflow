import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/text_styles.dart';

import 'package:stockflow/views/screens/login_Page.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<User?> logInUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            style: AppTextStyles.logoutHeading,
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: AppTextStyles.logoutBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child:
                  const Text("Cancel", style: AppTextStyles.logoutTwoButtons),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _auth.signOut(); // Perform logout

                // Navigate to SignInScreen and clear all previous screens
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  } // Reset password

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Mail sent";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }
}
