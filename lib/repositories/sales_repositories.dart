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
  Future<List<SalesModel>> getSales(String userId) async {
    // Add where clause to only get sales for the current user
    final snapshot = await _firestore
        .collection('sales')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => SalesModel.fromMap(doc.data())).toList();
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
