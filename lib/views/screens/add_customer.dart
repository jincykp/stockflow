import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/viewmodel/customer_provider.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/views/widgets/custom_form_builder.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Customer Information'),
      body: CustomFormBuilder(
        formKey: _formKey,
        title: 'Customer Information',
        subtitle: 'Enter the details of your new customer',
        isLoading: customerProvider.isLoading,
        formFields: [
          CustomFormBuilder.buildInputField(
            label: "Customer Name",
            icon: Icons.person_outline,
            controller: nameController,
            hintText: "Enter customer name",
          ),
          SizedBox(height: 16),

          // Two columns layout for email and phone
          Row(
            children: [
              Expanded(
                child: CustomFormBuilder.buildInputField(
                  label: "Email",
                  icon: Icons.email_outlined,
                  controller: emailController,
                  hintText: "Enter email",
                  keyboardType: TextInputType.emailAddress,
                  isEmail: true,
                  customValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!_isValidEmail(value)) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomFormBuilder.buildInputField(
                  label: "Phone",
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  hintText: "Enter phone number",
                  keyboardType: TextInputType.phone,
                  isMobileNumber: true,
                  customValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone is required";
                    }
                    if (!_isValidPhone(value)) {
                      return "Please enter a valid phone number";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          CustomFormBuilder.buildInputField(
            label: "Address",
            icon: Icons.location_on_outlined,
            controller: addressController,
            hintText: "Enter customer address",
            maxLines: 2,
          ),
          SizedBox(height: 16),

          CustomFormBuilder.buildInputField(
            label: "Notes",
            icon: Icons.note_outlined,
            controller: notesController,
            hintText: "Additional information (optional)",
            maxLines: 3,
            isRequired: false,
          ),
        ],
        tipWidget: CustomFormBuilder.buildTipWidget(
          message:
              "Building a customer database helps you track orders and personalize your services.",
        ),
        actionButton: CustomFormBuilder.buildActionButton(
          label: "Add Customer",
          icon: Icons.person_add_outlined,
          onPressed: _addCustomer,
          isLoading: customerProvider.isLoading,
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[0-9]{10,14}$').hasMatch(phone);
  }

  /// Function to handle adding customer using Provider
  Future<void> _addCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Get current user ID from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "User not authenticated!",
          isSuccess: false,
        );
        return;
      }

      final newCustomer = CustomerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        notes: notesController.text.trim(),
        createdAt: Timestamp.now(),
      );

      // Use provider to add customer
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final success = await customerProvider.addCustomer(newCustomer);

      if (success) {
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "Customer added successfully!",
          isSuccess: true,
        );

        // Navigate back to Home Page after adding customer
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      } else {
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "Failed to add customer: ${customerProvider.errorMessage}",
          isSuccess: false,
        );
      }
    }
  }
}
