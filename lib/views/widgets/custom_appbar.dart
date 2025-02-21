import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/colors.dart';

import 'package:stockflow/utils/theme/text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.appBarText,
      ),
      backgroundColor: AppColors.primaryColor, // Change color as needed
      centerTitle: true,
      foregroundColor: AppColors.textColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
