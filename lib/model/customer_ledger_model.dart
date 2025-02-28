import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/sales_model.dart';

class CustomerTransactionModel {
  final String id;
  final String userId;
  final String customerId;
  final String customerName;
  final String description;
  final double amount;
  final bool
      isDebit; // true if customer paid you, false if you charged customer
  final String reference; // e.g., invoice number, payment ID
  final Timestamp transactionDate;
  final String paymentMethod;
  final String? productId; // Optional if transaction is product-related
  final String? productName; // Optional product reference

  CustomerTransactionModel({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.description,
    required this.amount,
    required this.isDebit,
    required this.reference,
    required this.transactionDate,
    required this.paymentMethod,
    this.productId,
    this.productName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'customerId': customerId,
      'customerName': customerName,
      'description': description,
      'amount': amount,
      'isDebit': isDebit,
      'reference': reference,
      'transactionDate': transactionDate,
      'paymentMethod': paymentMethod,
      'productId': productId,
      'productName': productName,
    };
  }

  factory CustomerTransactionModel.fromMap(Map<String, dynamic> map) {
    return CustomerTransactionModel(
      id: map['id'],
      userId: map['userId'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      description: map['description'],
      amount: (map['amount'] ?? 0).toDouble(),
      isDebit: map['isDebit'] ?? false,
      reference: map['reference'] ?? '',
      transactionDate: map['transactionDate'] ?? Timestamp.now(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      productId: map['productId'],
      productName: map['productName'],
    );
  }

  // Factory to create transaction from sales
  factory CustomerTransactionModel.fromSalesModel(SalesModel sale) {
    return CustomerTransactionModel(
      id: sale.id,
      userId: sale.userId,
      customerId: sale.customerId,
      customerName: sale.customerName,
      description: "Sale: ${sale.productName} x${sale.quantity}",
      amount: sale.totalAmount,
      isDebit: false, // sale means customer owes money (not a payment)
      reference: "INV-${sale.id.substring(0, 6)}",
      transactionDate: sale.saleDate,
      paymentMethod: sale.paymentMethod,
      productId: sale.productId,
      productName: sale.productName,
    );
  }

  // Factory to create payment transaction
  static CustomerTransactionModel createPayment({
    required String id,
    required String userId,
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required Timestamp paymentDate,
    String reference = '',
  }) {
    return CustomerTransactionModel(
      id: id,
      userId: userId,
      customerId: customerId,
      customerName: customerName,
      description: "Payment received",
      amount: amount,
      isDebit: true, // payment means customer paid (is debited)
      reference: reference.isEmpty ? "PMT-${id.substring(0, 6)}" : reference,
      transactionDate: paymentDate,
      paymentMethod: paymentMethod,
    );
  }
}
