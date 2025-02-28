import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/item_report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch item reports for a specific user
  Future<List<ItemReportModel>> fetchItemReports(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('itemReports')
          .orderBy('reportDate', descending: true);

      // Apply date filters if provided
      if (startDate != null) {
        query = query.where('reportDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('reportDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ItemReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch item reports: $e');
    }
  }

  // Generate inventory status report
  Future<Map<String, dynamic>> generateInventoryStatusReport(
      String userId) async {
    try {
      // Fetch all item reports
      final List<ItemReportModel> items = await fetchItemReports(userId);

      // Calculate total inventory value
      double totalValue = 0;
      int totalItems = 0;
      List<Map<String, dynamic>> lowStockItems = [];

      for (var item in items) {
        // Add to total value
        totalValue += item.currentQuantity * item.currentPrice;

        // Add to total items count
        totalItems += item.currentQuantity;

        // Check for low stock
        if (item.isLowStock) {
          lowStockItems.add({
            'productId': item.productId,
            'productName': item.productName,
            'currentQuantity': item.currentQuantity,
            'initialQuantity': item.initialQuantity,
            'stockStatus': item.stockStatus,
          });
        }
      }

      // Create report
      return {
        'totalValue': totalValue,
        'totalItems': totalItems,
        'totalProducts': items.length,
        'lowStockItems': lowStockItems,
        'reportDate': Timestamp.now(),
      };
    } catch (e) {
      throw Exception('Failed to generate inventory status report: $e');
    }
  }

  // Generate item performance report
  Future<ItemPerformanceReport> generateItemPerformanceReport(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Fetch filtered item reports
      final List<ItemReportModel> items = await fetchItemReports(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Sort by sold quantity for top selling items
      List<ItemReportModel> topSellingItems = List.from(items);
      topSellingItems.sort((a, b) => b.soldQuantity.compareTo(a.soldQuantity));
      topSellingItems = topSellingItems.take(5).toList();

      // Sort by sold quantity for low selling items
      List<ItemReportModel> lowSellingItems = List.from(items);
      lowSellingItems.sort((a, b) => a.soldQuantity.compareTo(b.soldQuantity));
      lowSellingItems = lowSellingItems.take(5).toList();

      // Calculate total revenue
      double totalRevenue = items.fold(
          0, (previousValue, item) => previousValue + item.totalSales);

      // Calculate average turnover rate
      double avgTurnoverRate = items.isEmpty
          ? 0
          : items.fold(
                  0.0,
                  (previousValue, item) =>
                      previousValue + item.stockTurnoverRate) /
              items.length;

      return ItemPerformanceReport(
        topSellingItems: topSellingItems,
        lowSellingItems: lowSellingItems,
        totalRevenue: totalRevenue,
        averageTurnoverRate: avgTurnoverRate,
        reportDate: Timestamp.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate item performance report: $e');
    }
  }

  // Track item movement for a specific product
  Future<List<Map<String, dynamic>>> fetchItemMovements(
    String userId,
    String productId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get the item report
      final items = await fetchItemReports(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Find the specific product
      final productReport = items.firstWhere(
        (item) => item.productId == productId,
        orElse: () => throw Exception('Product not found'),
      );

      // Return all movements
      return productReport.movements;
    } catch (e) {
      throw Exception('Failed to fetch item movements: $e');
    }
  }
}
