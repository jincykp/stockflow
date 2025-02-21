import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String name;
  String description;
  int quantity;
  double price;
  Timestamp createdAt; // Add this field

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.createdAt, // Add this field
  });

  // Convert the model to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt, // Ensure this is included
    };
  }

  // Factory constructor to create a ProductModel from a Firestore document
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      createdAt:
          map['createdAt'] ?? Timestamp.now(), // Default to now if missing
    );
  }
}
