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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt,
    };
  }

  // Create from QueryDocumentSnapshot (used in your repository)
  factory ProductModel.fromSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Create from DocumentSnapshot (might be useful elsewhere)
  factory ProductModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Override equality operator to fix dropdown issue
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  // Override hashCode to match equality operator
  @override
  int get hashCode => id.hashCode;

  // Create a copy with modified properties
  ProductModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? quantity,
    double? price,
    Timestamp? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ProductModel{id: $id, name: $name, quantity: $quantity, price: $price}';
  }
}
