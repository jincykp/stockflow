import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/widgets/custom_buttons.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text);
      final price = double.tryParse(_priceController.text);

      if (quantity == null || price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid quantity or price format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(
        id: widget.product.id,
        name: _nameController.text,
        description: _descriptionController.text,
        quantity: quantity,
        price: price,
      )
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating product: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(title: "Edit Product"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a product name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter a price";
                    if (double.tryParse(value) == null)
                      return "Please enter a valid price";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter a quantity";
                    if (int.tryParse(value) == null)
                      return "Please enter a valid quantity";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a description" : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtons(
                    onPressed: _updateProduct,
                    text: 'Update Product Details',
                    backgroundColor: AppColors.primaryColor,
                    textColor: AppColors.textColor,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
