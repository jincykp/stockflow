import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockflow/model/sales_model.dart';
import 'package:stockflow/repositories/sales_repositories.dart';
import 'package:stockflow/viewmodel/product_provider.dart';

class SalesProvider with ChangeNotifier {
  final SalesRepository _repository;
  List<SalesModel> _salesList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  SalesProvider(this._repository);

  List<SalesModel> get salesList => _salesList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchSales(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = '';
      _salesList = await _repository.getSales(userId);
    } catch (e) {
      _errorMessage = 'Failed to fetch sales: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future addSale({
    required String userId,
    required String customerId,
    required String customerName,
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    required double totalAmount,
    required DateTime saleDate,
    required String paymentMethod,
    required ProductProvider productProvider, // Add this parameter
  }) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      // 1. Find the current product to get its details
      final currentProduct = productProvider.products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      // 2. Check if there's enough stock
      if (currentProduct.quantity < quantity) {
        throw Exception(
            'Not enough stock available. Only ${currentProduct.quantity} items left.');
      }

      // 3. Create the sale record
      final sale = SalesModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        customerId: customerId,
        customerName: customerName,
        productId: productId,
        productName: productName,
        quantity: quantity,
        price: price,
        totalAmount: totalAmount,
        createdAt: Timestamp.now(),
        saleDate: Timestamp.fromDate(saleDate),
        paymentMethod: paymentMethod,
      );

      // 4. Update product quantity (decrease stock)
      await productProvider.updateProduct(
        id: productId,
        name: currentProduct.name,
        description: currentProduct.description,
        quantity: currentProduct.quantity - quantity,
        price: currentProduct.price,
      );

      // 5. Add the sale record
      await _repository.addSales(sale);
      _salesList.insert(0, sale);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add sale: ${e.toString()}';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Filter sales by date range
  List<SalesModel> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    final start = Timestamp.fromDate(startDate);
    final end = Timestamp.fromDate(
        endDate.add(const Duration(days: 1))); // Include the full end date

    return _salesList.where((sale) {
      return sale.saleDate.compareTo(start) >= 0 &&
          sale.saleDate.compareTo(end) < 0;
    }).toList();
  }

  // Filter sales by payment method
  List<SalesModel> getSalesByPaymentMethod(String paymentMethod) {
    return _salesList
        .where((sale) => sale.paymentMethod == paymentMethod)
        .toList();
  }

  // Calculate total sales amount by payment method
  double getTotalSalesByPaymentMethod(String paymentMethod) {
    return getSalesByPaymentMethod(paymentMethod)
        .fold(0.0, (sum, sale) => sum + sale.totalAmount);
  }
}
