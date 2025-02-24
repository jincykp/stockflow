import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/views/screens/product_fullview.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class Product extends StatelessWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint('👤 Initializing with user: ${user.uid}');
      Provider.of<ProductProvider>(context, listen: false).initialize(user.uid);
    }

    return Scaffold(
      appBar: CustomAppBar(title: "Products"),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          debugPrint('🏗️ Product Widget rebuilt'); // Add this

          // Initial fetch
          if (productProvider.products.isEmpty && !productProvider.isLoading) {
            debugPrint('📱 Triggering initial fetch'); // Add this
            WidgetsBinding.instance.addPostFrameCallback((_) {
              debugPrint('🔄 Post frame callback triggered'); // Add this
              productProvider.fetchProducts();
            });
          }

          if (productProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productProvider.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.warningColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.fetchProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (productProvider.products.isEmpty) {
            return const Center(
              child: Text('No products found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStockStatusColor(product.quantity),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Qty: ${product.quantity}',
                                  style: const TextStyle(
                                    color: AppColors.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                _formatDate(product.createdAt),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStockStatusColor(int quantity) {
    if (quantity > 50) return Colors.green;
    if (quantity > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
