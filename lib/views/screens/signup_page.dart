import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/services/auth_services.dart';
import 'package:stockflow/services/auth_state_manager.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/utils/theme/spacing.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/screens/login_Page.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';
import 'package:stockflow/views/widgets/custom_textbutton.dart';
import 'package:stockflow/views/widgets/signup_textfields.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  AuthServices authServices = AuthServices();
  bool _isLoading = false;
  void _signup() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Store the returned user
      User? user = await authServices.createUserWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      if (user != null) {
        bool stateSet = await AuthStateManager.setLoggedIn();
        print("Auth state successfully set: $stateSet");

        // Verify login state was saved
        bool isLoggedIn = await AuthStateManager.isLoggedIn();
        print("User is logged in after signup: $isLoggedIn");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (error) {
      print("Signup Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${error.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with transparency
                    blurRadius: 10, // Increase for a softer, elevated effect
                    spreadRadius: 3, // How much the shadow spreads
                    offset:
                        Offset(5, 5), // X and Y position (direction of shadow)
                  ),
                ],
                color: Colors.white, // Background color
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Signup',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacing.heightsecond,
                      SignUpTextFields(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          final bool isValid =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value);
                          if (!isValid) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        hintText: "Email",
                      ),
                      Spacing.heightsecond,
                      SignUpTextFields(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          } else if (value.contains(' ')) {
                            return 'Password cannot contain whitespace';
                          }
                          return null;
                        },
                        hintText: "Password",
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(6)
                        ],
                      ),
                      Spacing.heightsecond,
                      CustomButtons(
                        text: "Signup",
                        onPressed: _isLoading ? null : _signup,
                        backgroundColor: AppColors.primaryColor,
                        textColor: AppColors.textColor,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        isLoading: _isLoading, // Add this parameter
                      ),
                      Spacing.heightsecond,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(fontSize: 12),
                          ),
                          CustomTextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  (MaterialPageRoute(
                                      builder: (context) => LoginPage())));
                            },
                            text: 'Login',
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
