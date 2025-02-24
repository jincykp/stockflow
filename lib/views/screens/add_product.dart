import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/repositories/product_repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/utils/theme/spacing.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';
import 'package:stockflow/views/widgets/signup_textfields.dart';
import 'package:stockflow/views/screens/home_page.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: 'Add Product'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildContainer(
                    icon: Icons.shopping_bag,
                    hintText: "Name",
                    controller: nameController),
                Spacing.heightsecond,
                _buildContainer(
                    icon: Icons.description,
                    hintText: "Description",
                    controller: descriptionController),
                Spacing.heightsecond,
                _buildContainer(
                    icon: Icons.format_list_numbered,
                    hintText: "Quantity",
                    controller: quantityController,
                    keyboardType: TextInputType.number),
                Spacing.heightsecond,
                _buildContainer(
                    icon: Icons.attach_money,
                    hintText: "Price",
                    controller: priceController,
                    keyboardType: TextInputType.number),
                Spacing.heightthird,

                // Custom Button with Loading State
                _isLoading
                    ? CircularProgressIndicator()
                    : CustomButtons(
                        text: "Add Product",
                        onPressed: _addProduct,
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

  /// ✅ Function to handle adding product
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Get current user ID from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not authenticated!")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final newProduct = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        userId: currentUser.uid, // Add the current user's ID here
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        price: double.parse(priceController.text.trim()),
        createdAt: Timestamp.now(),
      );

      try {
        await ProductRepository().addProduct(newProduct);

        // ✅ Navigate back to Home Page after adding product
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        debugPrint("Error adding product: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add product!")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ Reusable Input Field Container
  Widget _buildContainer({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
              offset: Offset(3, 3),
            ),
          ],
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 35,
              color: AppColors.primaryShadeTwoColor,
            ),
            Spacing.widthSecond,
            Expanded(
              child: SignUpTextFields(
                controller: controller,
                keyboardType: keyboardType,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "$hintText is required";
                  }
                  return null;
                },
                hintText: hintText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
