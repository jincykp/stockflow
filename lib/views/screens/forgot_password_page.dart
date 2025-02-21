import 'package:flutter/material.dart';
import 'package:stockflow/services/auth_services.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/login_Page.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';
import 'package:stockflow/views/widgets/signup_textfields.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _auth = AuthServices();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.resetPassword(_emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An email for password reset has been sent to your email.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your email to receive a password reset link.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: screenWidth * 0.1),
                SignUpTextFields(
                  controller: _emailController,
                  hintText: "Enter your Email",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                        .hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenWidth * 0.1),
                CustomButtons(
                  text: "Send Email",
                  onPressed: _resetPassword,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.textColor,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
