import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:stockflow/services/auth_services.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/utils/theme/spacing.dart';
import 'package:stockflow/views/screens/forgot_password_page.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/screens/signup_page.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';
import 'package:stockflow/views/widgets/custom_textbutton.dart';
import 'package:stockflow/views/widgets/signup_textfields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthServices authServices = AuthServices();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
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
                child: SizedBox(
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Spacing.heightfirst,
                          SignUpTextFields(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
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
                            hintText: "email",
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
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              LengthLimitingTextInputFormatter(6)
                            ],
                            hintText: "password",
                          ),
                          Spacing.heightsecond,
                          CustomTextButton(
                              text: "Forgot password",
                              textColor: AppColors.warningColor,
                              fontSize: 10,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage()));
                              }),
                          Spacing.heightfirst,
                          CustomButtons(
                              text: "Login",
                              onPressed: _handleLogin,
                              backgroundColor: AppColors.primaryColor,
                              textColor: AppColors.textColor,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight),
                          Spacing.heightsecond,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "You don't have an account?",
                                style: TextStyle(fontSize: 11),
                              ),
                              CustomTextButton(
                                  text: "Sign Up",
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignupPage()));
                                  }),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warningColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (formKey.currentState!.validate()) {
      try {
        final user = await authServices.logInUserWithEmailAndPassword(
          emailController.text,
          passwordController.text,
        );

        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _showErrorSnackBar('Invalid email or password');
        }
      } catch (e) {
        _showErrorSnackBar('Email or password does not match');
      }
    }
  }
}
