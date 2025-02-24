import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final Timestamp createdAt;

  ProductModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt,
    };
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      price: (data['price'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
