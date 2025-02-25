import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/repositories/product_repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/screens/home_page.dart';
import 'package:stockflow/views/widgets/custom_form_builder.dart'; // Import the new widget

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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Product Information'),
      body: CustomFormBuilder(
        formKey: _formKey,
        title: 'Product Information',
        subtitle: 'Enter the details of your new product',
        isLoading: _isLoading,
        formFields: [
          CustomFormBuilder.buildInputField(
            label: "Product Name",
            icon: Icons.shopping_bag_outlined,
            controller: nameController,
            hintText: "Enter product name",
          ),
          SizedBox(height: 16),

          CustomFormBuilder.buildInputField(
            label: "Description",
            icon: Icons.description_outlined,
            controller: descriptionController,
            hintText: "Enter product description",
            maxLines: 3,
          ),
          SizedBox(height: 16),

          // Two columns layout for quantity and price
          Row(
            children: [
              Expanded(
                child: CustomFormBuilder.buildInputField(
                  label: "Quantity",
                  icon: Icons.inventory_2_outlined,
                  controller: quantityController,
                  hintText: "Enter quantity",
                  keyboardType: TextInputType.number,
                  customValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Quantity is required";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid quantity";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomFormBuilder.buildInputField(
                  label: "Price",
                  icon: Icons.attach_money,
                  controller: priceController,
                  hintText: "Enter price",
                  keyboardType: TextInputType.number,
                  prefixText: "\$",
                  customValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Price is required";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid price";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
        tipWidget: CustomFormBuilder.buildTipWidget(
          message:
              "Adding detailed product information helps with inventory tracking and reporting.",
        ),
        actionButton: CustomFormBuilder.buildActionButton(
          label: "Add Product",
          icon: Icons.add_circle_outline,
          onPressed: _addProduct,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  /// Function to handle adding product
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Get current user ID from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "User not authenticated!",
          isSuccess: false,
        );
        setState(() => _isLoading = false);
        return;
      }

      final newProduct = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        price: double.parse(priceController.text.trim()),
        createdAt: Timestamp.now(),
      );

      try {
        await ProductRepository().addProduct(newProduct);
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "Product added successfully!",
          isSuccess: true,
        );

        // Navigate back to Home Page after adding product
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } catch (e) {
        debugPrint("Error adding product: $e");
        CustomFormBuilder.showSnackBar(
          context: context,
          message: "Failed to add product!",
          isSuccess: false,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
