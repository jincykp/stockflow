import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/repositories/product_repositories.dart';
import 'package:uuid/uuid.dart';

class AddProductViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> addProduct({
    required String name,
    required String description,
    required String quantity,
    required String price,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String productId = const Uuid().v4(); // Generate a unique ID
      ProductModel product = ProductModel(
        id: productId,
        name: name,
        description: description,
        quantity: int.parse(quantity),
        price: double.parse(price),
        createdAt: Timestamp.now(), // Corrected this line
      );

      await _repository.addProduct(product);

      // Navigate to HomeScreen
    } catch (e) {
      debugPrint("Error adding product: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
