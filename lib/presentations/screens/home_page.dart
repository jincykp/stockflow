import 'package:flutter/material.dart';
import 'package:stockflow/core/theme/colors.dart';
import 'package:stockflow/data/repositories/auth_services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthServices authServices = AuthServices();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        actions: [
          IconButton(
              onPressed: () {
                authServices.signOut(context);
              },
              icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}
