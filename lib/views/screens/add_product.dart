import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/repositories/product_repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Product Information'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    "Enter the details of your new product",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildInputField(
                            label: "Product Name",
                            icon: Icons.shopping_bag_outlined,
                            controller: nameController,
                            hintText: "Enter product name",
                          ),
                          SizedBox(height: 16),

                          _buildInputField(
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
                                child: _buildInputField(
                                  label: "Quantity",
                                  icon: Icons.inventory_2_outlined,
                                  controller: quantityController,
                                  hintText: "Enter quantity",
                                  keyboardType: TextInputType.number,
                                  prefixText: "",
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  label: "Price",
                                  icon: Icons.attach_money,
                                  controller: priceController,
                                  hintText: "Enter price",
                                  keyboardType: TextInputType.number,
                                  prefixText: "\$",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          // Add some tips
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tips_and_updates,
                                    color: Colors.blue[300]),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Adding detailed product information helps with inventory tracking and reporting.",
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add Product Button
                  SizedBox(height: 16),
                  _buildAddButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String prefixText = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: prefixText,
              prefixIcon: Icon(icon, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.textColor,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "$label is required";
              }
              if (label == "Price" && double.tryParse(value) == null) {
                return "Please enter a valid price";
              }
              if (label == "Quantity" && int.tryParse(value) == null) {
                return "Please enter a valid quantity";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textColor,
          elevation: 3,
          shadowColor: AppColors.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
        _showErrorSnackBar("User not authenticated!");
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
        _showSuccessSnackBar("Product added successfully!");

        // Navigate back to Home Page after adding product
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      } catch (e) {
        debugPrint("Error adding product: $e");
        _showErrorSnackBar("Failed to add product!");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.textColor),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: AppColors.textColor),
            SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
