import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor, // Uses primary color
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.standardBlackColor, // Darker text color for subheadings
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.standardBlackColor, // Regular black text
  );

  static const TextStyle warningText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.warningColor, // Uses warning color (red)
  );

  static const TextStyle appBarText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    // Uses white text
  );

  static const TextStyle smallText = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.lightShadeColor);

  static const TextStyle logoutHeading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor, // Uses primary color
  );
  static const TextStyle logoutBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.standardBlackColor, // Uses primary color
  );
  static const TextStyle logoutTwoButtons = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor, // Uses primary color
  );
  static const TextStyle bottomNavItmes = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textColor, // Uses primary color
  );
}
