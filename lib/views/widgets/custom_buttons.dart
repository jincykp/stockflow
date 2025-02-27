import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double screenWidth;
  final double screenHeight;
  final bool isLoading;

  const CustomButtons({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.screenWidth,
    required this.screenHeight,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  CustomButtons copyWith({
    String? text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? screenWidth,
    double? screenHeight,
    bool? isLoading,
  }) {
    return CustomButtons(
      text: text ?? this.text,
      onPressed: onPressed ?? this.onPressed,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
