import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/views/screens/add_product.dart';
import 'package:stockflow/views/screens/product_fullview.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();

    // Perform initialization after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('Initializing with user: ${user.uid}');
        Provider.of<ProductProvider>(context, listen: false)
            .initialize(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Remove the duplicate initialization from here
    // This was causing the error

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              foregroundColor: AppColors.textColor,
              backgroundColor: AppColors.primaryColor,
              title: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.textColor,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textColor,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.textColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ],
            )
          : AppBar(
              foregroundColor: AppColors.textColor,
              backgroundColor: AppColors.primaryColor,
              title: const Text(
                "Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.textColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ],
            ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          debugPrint('Product Widget rebuilt');

          // Check if we need to fetch data first
          if (productProvider.products.isEmpty &&
              !productProvider.isLoading &&
              productProvider.error.isEmpty &&
              !_initialFetchDone) {
            debugPrint('Triggering initial fetch');
            _initialFetchDone = true; // Prevent multiple fetch calls
            WidgetsBinding.instance.addPostFrameCallback((_) {
              debugPrint('Post frame callback triggered');
              productProvider.fetchProducts();
            });
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
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

          if (productProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          // Filter products based on search query
          final filteredProducts = _searchQuery.isEmpty
              ? productProvider.products
              : productProvider.products.where((product) {
                  return product.name.toLowerCase().contains(_searchQuery) ||
                      product.description.toLowerCase().contains(_searchQuery);
                }).toList();

          // Handle empty states after all data operations
          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 44,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products matching "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                        if (_isSearching) {
                          _isSearching = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryShadeTwoColor,
                      foregroundColor: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search result count
              if (_searchQuery.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Text(
                        'Found ${filteredProducts.length} result${filteredProducts.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => productProvider.fetchProducts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddProduct()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
        backgroundColor: AppColors.primaryShadeTwoColor,
        foregroundColor: AppColors.textColor,
        shape: const CircleBorder(),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
              // Highlight matching text in description if searching
              _searchQuery.isEmpty
                  ? Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    )
                  : _highlightText(
                      product.description,
                      _searchQuery,
                      TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Color(0xFFFFEB3B),
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
                      color: AppColors.successColor,
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
  }

  // Highlights text based on search query
  Widget _highlightText(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) {
      return Text(text, style: normalStyle);
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    String textLower = text.toLowerCase();
    String queryLower = query.toLowerCase();

    while (true) {
      indexOfHighlight = textLower.indexOf(queryLower, start);
      if (indexOfHighlight < 0) {
        // No more matches
        spans.add(TextSpan(
          text: text.substring(start),
          style: normalStyle,
        ));
        break;
      }

      if (indexOfHighlight > start) {
        // Add non-highlighted text
        spans.add(TextSpan(
          text: text.substring(start, indexOfHighlight),
          style: normalStyle,
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + query.length),
        style: highlightStyle,
      ));

      // Update start for next search
      start = indexOfHighlight + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  Color _getStockStatusColor(int quantity) {
    if (quantity > 50) return AppColors.successColor;
    if (quantity > 20) return AppColors.mediumColor;
    return AppColors.warningColor;
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
