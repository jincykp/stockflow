import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'allproducts';

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(collection)
          .doc(product.id)
          .set(product.toMap());
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }

  // Fetch products for specific user

  Future<List<ProductModel>> fetchProducts(String userId) async {
    try {
      debugPrint('Attempting to fetch products for userId: $userId');

      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('Fetched ${snapshot.docs.length} documents');

      final products = snapshot.docs.map((doc) {
        try {
          return ProductModel.fromSnapshot(doc);
        } catch (e) {
          debugPrint('Error parsing document ${doc.id}: $e');
          debugPrint('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();

      debugPrint('Successfully parsed ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('Error in fetchProducts: $e');
      throw Exception("Failed to fetch products: $e");
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(collection).doc(product.id).update({
        'name': product.name,
        'description': product.description,
        'quantity': product.quantity,
        'price': product.price,
        // Don't update userId as it shouldn't change
      });
    } catch (e) {
      throw Exception("Failed to update product: $e");
    }
  }

  // You might want to add a check to ensure users can only delete their own products
  Future<void> deleteProduct(String id, String userId) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists && doc.get('userId') == userId) {
        await _firestore.collection(collection).doc(id).delete();
      } else {
        throw Exception("Unauthorized to delete this product");
      }
    } catch (e) {
      throw Exception("Failed to delete product: $e");
    }
  }
}
