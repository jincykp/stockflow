import 'package:cloud_firestore/cloud_firestore.dart';

class SalesModel {
  final String id;
  final String userId;
  final String customerId;
  final String customerName; // For easy reference
  final String productId;
  final String productName; // For easy reference
  final int quantity;
  final double price;
  final double totalAmount;
  final Timestamp createdAt;
  // New fields
  final Timestamp saleDate;
  final String paymentMethod;

  SalesModel({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.createdAt,
    required this.saleDate,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'customerId': customerId,
      'customerName': customerName,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'saleDate': saleDate,
      'paymentMethod': paymentMethod,
    };
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'],
      userId: map['userId'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      totalAmount: map['totalAmount'],
      createdAt: map['createdAt'],
      saleDate: map['saleDate'] ??
          map['createdAt'], // Fallback for backward compatibility
      paymentMethod: map['paymentMethod'] ??
          'Cash', // Default value for backward compatibility
    );
  }
}
