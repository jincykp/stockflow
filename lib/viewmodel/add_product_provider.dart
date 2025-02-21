import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/repositories/product_repositories.dart';
import 'package:uuid/uuid.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Add Product
  Future<void> addProduct({
    required String name,
    required String description,
    required String quantity,
    required String price,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String productId = const Uuid().v4();
      ProductModel product = ProductModel(
        id: productId,
        name: name,
        description: description,
        quantity: int.parse(quantity),
        price: double.parse(price),
        createdAt: Timestamp.now(),
      );

      await _repository.addProduct(product);
      await fetchProducts(); // Refresh the products list after adding
    } catch (e) {
      _error = "Error adding product: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('allproducts')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          quantity: data['quantity'],
          price: data['price'].toDouble(),
          createdAt: data['createdAt'],
        );
      }).toList();
    } catch (e) {
      _error = 'Failed to fetch products: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
