import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpTextFields extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  String? Function(String?)? validator;
  final TextInputType? KeyboardType;
  final List<TextInputFormatter>? inputFormatters;
  SignUpTextFields(
      {super.key,
      required this.controller,
      required this.validator,
      required this.hintText,
      this.inputFormatters,
      this.KeyboardType,
      TextStyle? hintStyle});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: KeyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText, // ✅ Add hintText here
          hintStyle: TextStyle(color: Colors.grey), // Optional styling
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ));
  }
}
