import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/repositories/product_repositories.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _error = '';
  String? _currentUserId;

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;
  String? get currentUserId => _currentUserId;

  // Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchProducts(); // Fetch products after setting user ID
  }

  Future<void> fetchProducts() async {
    debugPrint('⚡️ PROVIDER: fetchProducts called'); // Add this line first

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      debugPrint('❌ PROVIDER: No user ID found'); // Add this
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      debugPrint('👤 PROVIDER: Current user ID: $_currentUserId');
      _products = await _repository.fetchingProducts(_currentUserId!);
      debugPrint('✅ PROVIDER: Fetch completed');
    } catch (e) {
      debugPrint('❌ PROVIDER: Error - $e');
      _error = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String quantity,
    required String price,
  }) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      throw Exception("User not authenticated");
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        name: name,
        description: description,
        quantity: int.parse(quantity),
        price: double.parse(price),
        createdAt: Timestamp.now(),
      );

      await _repository.addProduct(product);
      await fetchProducts(); // Refresh the list after adding
    } catch (e) {
      _error = "Error adding product: $e";
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required int quantity,
    required double price,
  }) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      throw Exception("User not authenticated");
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedProduct = ProductModel(
        id: id,
        userId: _currentUserId!,
        name: name,
        description: description,
        quantity: quantity,
        price: price,
        createdAt: Timestamp.now(),
      );

      await _repository.updateProduct(updatedProduct);
      await fetchProducts(); // Refresh the list after updating
    } catch (e) {
      _error = "Error updating product: $e";
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      throw Exception("User not authenticated");
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.deleteProduct(id, _currentUserId!);
      await fetchProducts(); // Refresh the list after deleting
    } catch (e) {
      _error = "Error deleting product: $e";
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
