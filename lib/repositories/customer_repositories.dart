import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  final String _customersCollection = 'customers';

  // Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore
        .collection(_customersCollection)
        .doc(customer.id)
        .set(customer.toMap());
  }

  // Get all customers for a specific user
  Future<List<CustomerModel>> getCustomers(String userId) async {
    try {
      // Simpler query that doesn't require a composite index
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('userId', isEqualTo: userId)
          // .orderBy('createdAt', descending: true) - Remove this line temporarily
          .get();

      return snapshot.docs.map((doc) {
        // Create a new map with all the existing data plus the id
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID to the map

        return CustomerModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      throw e;
    }
  }

  // Get a specific customer
  Future<CustomerModel?> getCustomer(String customerId) async {
    final doc =
        await _firestore.collection(_customersCollection).doc(customerId).get();

    if (doc.exists) {
      return CustomerModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update customer
  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore
        .collection(_customersCollection)
        .doc(customer.id)
        .update(customer.toMap());
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection(_customersCollection).doc(customerId).delete();
  }
}
