import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/services/auth_services.dart';
import 'package:stockflow/services/auth_state_manager.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/utils/theme/spacing.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';
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
                        hintText: "password",
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LengthLimitingTextInputFormatter(6)
                        ],
                      ),
                      Spacing.heightsecond,
                      CustomButtons(
                          text: "Signup",
                          onPressed: () {
                            // In your SignupPage, modify the successful signup handler:
                            if (formKey.currentState!.validate()) {
                              authServices
                                  .createUserWithEmailAndPassword(
                                emailController.text,
                                passwordController.text,
                              )
                                  .then((_) async {
                                await AuthStateManager
                                    .setLoggedIn(); // Set login state
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                  (route) => false,
                                );
                              }).catchError((error) {
                                print("Signup Error: $error");
                              });
                            }
                          },
                          backgroundColor: AppColors.primaryColor,
                          textColor: AppColors.textColor,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                      Spacing.heightsecond,
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
