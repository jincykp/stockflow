import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockflow/core/theme/colors.dart';
import 'package:stockflow/core/theme/spacing.dart';
import 'package:stockflow/presentations/widgets/custom_buttons.dart';
import 'package:stockflow/presentations/widgets/custom_textbutton.dart';
import 'package:stockflow/presentations/widgets/signup_textfields.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    GlobalKey formKey = GlobalKey();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Center(
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            hintText: "password",
                          ),
                          Spacing.heightsecond,
                          CustomTextButton(
                              text: "Forgot password",
                              textColor: AppColors.warningColor,
                              fontSize: 10,
                              onPressed: () {}),
                          Spacing.heightfirst,
                          CustomButtons(
                              text: "Log In",
                              onPressed: () {},
                              backgroundColor: AppColors.primaryColor,
                              textColor: AppColors.textColor,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight),
                          Spacing.heightsecond,
                          CustomTextButton(text: "Sign Up", onPressed: () {})
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
