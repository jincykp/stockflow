import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/colors.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = AppColors.primaryColor,
    this.fontSize = 14.0,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
        foregroundColor: textColor,
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }
}
