import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<List<ProductModel>> fetchingProducts(String userId) async {
    try {
      // Debug Point 1: Check input userId
      debugPrint('\n[DEBUG] Starting fetch with userId: $userId');

      // Debug Point 2: Verify Firebase Auth
      final currentAuthUser = FirebaseAuth.instance.currentUser;
      debugPrint('[DEBUG] Current Auth User ID: ${currentAuthUser?.uid}');
      if (currentAuthUser == null) {
        debugPrint('[DEBUG] ⚠️ No authenticated user found!');
        return [];
      }

      // Debug Point 3: Verify collection reference
      debugPrint('[DEBUG] Querying collection: $collection');

      // Debug Point 4: Execute query
      debugPrint('[DEBUG] Executing Firestore query...');
      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();

      // Debug Point 5: Check query results
      debugPrint('[DEBUG] Query returned ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        debugPrint('[DEBUG] ⚠️ No documents found for this user!');
        // Print a sample query to verify
        final sampleDocs =
            await _firestore.collection(collection).limit(1).get();
        if (sampleDocs.docs.isNotEmpty) {
          debugPrint(
              '[DEBUG] Sample document data: ${sampleDocs.docs.first.data()}');
        }
      }

      // Debug Point 6: Document conversion
      final List<ProductModel> products = [];
      for (var doc in snapshot.docs) {
        try {
          debugPrint('\n[DEBUG] Converting doc ${doc.id}');
          debugPrint('[DEBUG] Document data: ${doc.data()}');
          final product = ProductModel.fromSnapshot(doc);
          products.add(product);
          debugPrint('[DEBUG] ✅ Successfully converted document');
        } catch (e) {
          debugPrint('[DEBUG] ❌ Error converting document: $e');
        }
      }

      debugPrint('[DEBUG] Final products count: ${products.length}');
      return products;
    } catch (e) {
      debugPrint('[DEBUG] ❌ Fatal error in fetchProducts: $e');
      rethrow;
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
      throw Exception(
          "Failed to delete product: $e"); // Fixed typo: Excepetion -> Exception
    }
  }
}
