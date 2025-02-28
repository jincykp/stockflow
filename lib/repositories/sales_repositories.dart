import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/sales_model.dart';

class SalesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new sales record
  Future<void> addSales(SalesModel sales) async {
    try {
      await _firestore.collection('sales').doc(sales.id).set(sales.toMap());
      debugPrint('Sale added successfully with ID: ${sales.id}');
    } catch (e) {
      debugPrint('Error adding sale: $e');
      throw e;
    }
  }

  // Get all sales for a user
  // In SalesRepository class
  Future<List<SalesModel>> getSales(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('sales')
          .where('userId', isEqualTo: userId)
          // Add this to enable offline persistence
          .get(const GetOptions(source: Source.serverAndCache));

      debugPrint(
          'Retrieved ${snapshot.docs.length} sales records for user $userId');
      return snapshot.docs
          .map((doc) => SalesModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching sales: $e');
      // Try cache if server fails
      try {
        debugPrint('Attempting to fetch from cache');
        final cacheSnapshot = await _firestore
            .collection('sales')
            .where('userId', isEqualTo: userId)
            .get(const GetOptions(source: Source.cache));

        return cacheSnapshot.docs
            .map((doc) => SalesModel.fromMap(doc.data()))
            .toList();
      } catch (cacheError) {
        debugPrint('Cache fetch also failed: $cacheError');
        throw e;
      }
    }
  }

  // Delete a sales record
  Future<void> deleteSales(String salesId) async {
    try {
      await _firestore.collection('sales').doc(salesId).delete();
      debugPrint('Sale deleted successfully with ID: $salesId');
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      throw e;
    }
  }

  // Update a sales record
  Future<void> updateSales(SalesModel sales) async {
    try {
      await _firestore.collection('sales').doc(sales.id).update(sales.toMap());
      debugPrint('Sale updated successfully with ID: ${sales.id}');
    } catch (e) {
      debugPrint('Error updating sale: $e');
      throw e;
    }
  }
}
