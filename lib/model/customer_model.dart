import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final Timestamp createdAt;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      notes: map['notes'],
      createdAt: map['createdAt'],
    );
  }
}
