// models/item_report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemReportModel {
  final String productId;
  final String productName;
  final int currentQuantity;
  final double currentPrice;
  final int initialQuantity;
  final int soldQuantity;
  final double totalSales;
  final List<Map<String, dynamic>> movements; // Stock changes over time
  final Timestamp reportDate;

  ItemReportModel({
    required this.productId,
    required this.productName,
    required this.currentQuantity,
    required this.currentPrice,
    required this.initialQuantity,
    required this.soldQuantity,
    required this.totalSales,
    required this.movements,
    required this.reportDate,
  });

  // Factory method to create from Firestore document
  factory ItemReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemReportModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      currentQuantity: data['currentQuantity'] ?? 0,
      currentPrice: data['currentPrice'] ?? 0.0,
      initialQuantity: data['initialQuantity'] ?? 0,
      soldQuantity: data['soldQuantity'] ?? 0,
      totalSales: data['totalSales'] ?? 0.0,
      movements: List<Map<String, dynamic>>.from(data['movements'] ?? []),
      reportDate: data['reportDate'] ?? Timestamp.now(),
    );
  }

  // Convert to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'currentQuantity': currentQuantity,
      'currentPrice': currentPrice,
      'initialQuantity': initialQuantity,
      'soldQuantity': soldQuantity,
      'totalSales': totalSales,
      'movements': movements,
      'reportDate': reportDate,
    };
  }

  // Calculate stock turnover rate (how quickly inventory is sold)
  double get stockTurnoverRate {
    if (initialQuantity == 0) return 0.0;
    return soldQuantity / initialQuantity;
  }

  // Calculate revenue per unit
  double get revenuePerUnit {
    if (soldQuantity == 0) return 0.0;
    return totalSales / soldQuantity;
  }

  // Calculate if this is a low stock item
  bool get isLowStock {
    // Define low stock as less than 10 items or less than 20% of initial stock
    return currentQuantity < 10 ||
        (initialQuantity > 0 && currentQuantity / initialQuantity < 0.2);
  }

  // Get stock status label
  String get stockStatus {
    if (currentQuantity <= 0) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    if (currentQuantity > initialQuantity * 0.8) return 'Well Stocked';
    return 'Medium Stock';
  }
}

// Additional models for more specific reports

class InventoryStatusReport {
  final double totalValue;
  final int totalItems;
  final int totalProducts;
  final List<Map<String, dynamic>> lowStockItems;
  final Timestamp reportDate;

  InventoryStatusReport({
    required this.totalValue,
    required this.totalItems,
    required this.totalProducts,
    required this.lowStockItems,
    required this.reportDate,
  });
}

class ItemPerformanceReport {
  final List<ItemReportModel> topSellingItems;
  final List<ItemReportModel> lowSellingItems;
  final double totalRevenue;
  final double averageTurnoverRate;
  final Timestamp reportDate;

  ItemPerformanceReport({
    required this.topSellingItems,
    required this.lowSellingItems,
    required this.totalRevenue,
    required this.averageTurnoverRate,
    required this.reportDate,
  });
}
