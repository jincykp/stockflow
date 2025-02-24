import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/views/screens/product_edit.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/model/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel currentProduct;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.microtask(() {
      if (_mounted) {
        _refreshProductData();
      }
    });
  }

  Future<void> _refreshProductData() async {
    if (!_mounted) return;

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.fetchProducts();

      if (!_mounted) return;

      final updatedProduct = productProvider.products.firstWhere(
        (p) => p.id == currentProduct.id,
        orElse: () => currentProduct,
      );

      setState(() {
        currentProduct = updatedProduct;
      });
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing data: $e')),
        );
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (!_mounted) return;

    try {
      final updatedProduct = await Navigator.push<ProductModel>(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductScreen(product: currentProduct),
        ),
      );

      if (!_mounted) return;

      if (updatedProduct != null) {
        setState(() {
          currentProduct = updatedProduct;
        });
        await _refreshProductData();
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Product Details"),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final latestProduct = provider.products.firstWhere(
            (p) => p.id == currentProduct.id,
            orElse: () => currentProduct,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryShadeThreeColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestProduct.name,
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${latestProduct.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stock Status Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  _getStockStatusColor(latestProduct.quantity),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: AppColors.textColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Stock',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightShadeColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${latestProduct.quantity} units',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Description Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            latestProduct.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.lightShadeColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Additional Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Additional Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _navigateToEdit,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _showDeleteConfirmation(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Added Date',
                            value: _formatDate(latestProduct.createdAt),
                          ),
                          const SizedBox(height: 12),
                          DetailRow(
                            icon: Icons.local_offer,
                            label: 'Stock Status',
                            value: _getStockStatus(latestProduct.quantity),
                            valueColor:
                                _getStockStatusColor(latestProduct.quantity),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content:
              Text('Are you sure you want to delete ${currentProduct.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final productProvider =
                    Provider.of<ProductProvider>(context, listen: false);
                try {
                  await productProvider.deleteProduct(currentProduct.id);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to product list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.successColor,
                      content: Text(
                        'Product deleted successfully',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.warningColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.specialColor,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.standardBlackColor,
          ),
        ),
      ],
    );
  }
}

Color _getStockStatusColor(int quantity) {
  if (quantity > 50) return AppColors.successColor;
  if (quantity > 20) return AppColors.mediumColor;
  return AppColors.warningColor;
}

String _getStockStatus(int quantity) {
  if (quantity > 50) return 'High Stock';
  if (quantity > 20) return 'Medium Stock';
  return 'Low Stock';
}

String _formatDate(Timestamp timestamp) {
  final date = timestamp.toDate();
  return '${date.day}/${date.month}/${date.year}';
}
