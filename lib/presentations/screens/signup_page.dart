import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/core/theme/colors.dart';
import 'package:stockflow/core/theme/spacing.dart';
import 'package:stockflow/data/repositories/auth_services.dart';
import 'package:stockflow/presentations/screens/home_page.dart';
import 'package:stockflow/presentations/widgets/custom_buttons.dart';
import 'package:stockflow/presentations/widgets/signup_textfields.dart';

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
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Signup',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          if (formKey.currentState!.validate()) {
                            authServices.createUserWithEmailAndPassword(
                                emailController.text, passwordController.text);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
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
    );
  }
}
