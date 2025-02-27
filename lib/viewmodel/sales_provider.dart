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
      debugPrint("Fetching sales for user ID: $userId");
      _salesList = await _repository.getSales(userId);
      debugPrint("Found ${_salesList.length} sales records");
    } catch (e) {
      _errorMessage = 'Failed to fetch sales: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addSale({
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
    required ProductProvider productProvider,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = '';

      // 1. Check if there's enough stock
      final currentProduct = productProvider.products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      if (currentProduct.quantity < quantity) {
        throw Exception(
            'Not enough stock available. Only ${currentProduct.quantity} items left.');
      }

      // 2. Create the sale record
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

      // 3. Add the sale record to database
      await _repository.addSales(sale);

      // 4. Update product stock - this is the ONLY place where stock should be updated
      // The UI layer (AddSalesDetails) should NOT update stock again
      await productProvider.updateProductStock(
          productId, currentProduct.quantity - quantity);

      // 5. Update local sales list
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

  // Calculate total sales amount for all sales
  double getTotalSalesAmount() {
    return _salesList.fold(0.0, (sum, sale) => sum + sale.totalAmount);
  }

  // Get total number of sales
  int getTotalSalesCount() {
    return _salesList.length;
  }

  // Get sales for a specific product
  List<SalesModel> getSalesByProductId(String productId) {
    return _salesList.where((sale) => sale.productId == productId).toList();
  }

  // Get sales for a specific customer
  List<SalesModel> getSalesByCustomerId(String customerId) {
    return _salesList.where((sale) => sale.customerId == customerId).toList();
  }
}
