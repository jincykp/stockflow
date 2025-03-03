import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/repositories/item_export_files.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/product_provider.dart';

class ItemReportScreen extends StatefulWidget {
  const ItemReportScreen({super.key});

  @override
  State<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends State<ItemReportScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Refresh products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  final ItemExportFiles _exportFiles = ItemExportFiles();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        title: const Text('Inventory Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ProductProvider>(context, listen: false)
                  .fetchProducts();
            },
          ),
          // Add this line
          PopupMenuButton<String>(
            onSelected: (value) {
              // Get the product list from provider
              final products =
                  Provider.of<ProductProvider>(context, listen: false).products;

              switch (value) {
                case 'Print':
                  _exportFiles.printInventoryReport(context, products);
                  break;
                case 'Excel':
                  _exportFiles.downloadExcel(context, products);
                  break;
                case 'Pdf':
                  _exportFiles.downloadPdf(context, products);
                  break;
                case 'Email':
                  _exportFiles.sendEmail(context, products);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Print', child: Text('Print')),
              PopupMenuItem(value: 'Excel', child: Text('Excel')),
              PopupMenuItem(value: 'Pdf', child: Text('Pdf')),
              PopupMenuItem(value: 'Email', child: Text('Email')),
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          }

          if (productProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${productProvider.error}',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => productProvider?.fetchProducts(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (productProvider.products.isEmpty) {
            return const Center(
              child:
                  Text('No products found. Add some products to view report.'),
            );
          }

          return _buildReportContent(productProvider.products);
        },
      ),
    );
  }

  Widget _buildReportContent(List<ProductModel> products) {
    return Column(
      children: [
        _buildReportHeader(),
        Expanded(
          child: ListView(
            children: [
              // Summary statistics card
              _buildSummaryCard(products),
              const SizedBox(height: 10),
              // Detailed product table
              _buildProductTable(products),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            'Inventory Status Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryShadeThreeColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<ProductModel> products) {
    // Calculate summary statistics
    final totalProducts = products.length;
    final totalQuantity =
        products.fold<int>(0, (sum, product) => sum + product.quantity);
    final totalValue = products.fold<double>(
        0, (sum, product) => sum + (product.price * product.quantity));
    final lowStock = products.where((p) => p.quantity < 10).length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow('Total Products', '$totalProducts items'),
            _buildSummaryRow('Total Quantity', '$totalQuantity units'),
            _buildSummaryRow(
                'Total Inventory Value', currencyFormat.format(totalValue)),
            _buildSummaryRow('Low Stock Items', '$lowStock items',
                isWarning: lowStock > 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(List<ProductModel> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 50,
        horizontalMargin: 24, // Margin on left and right of the table
        headingRowHeight: 60, // More height for the header row
        dataRowHeight: 70,
        // Remove dataRowMinHeight or dataRowHeight to let rows adjust naturally
        columns: [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Quantity'), numeric: true),
          DataColumn(label: Text('Price'), numeric: true),
          DataColumn(label: Text('Total Value'), numeric: true),
          DataColumn(label: Text('Status')),
        ],
        rows: products.map((product) {
          final totalValue = product.price * product.quantity;
          String status = 'In Stock';
          Color statusColor = Colors.green;

          if (product.quantity <= 0) {
            status = 'Out of Stock';
            statusColor = Colors.red;
          } else if (product.quantity < 10) {
            status = 'Low Stock';
            statusColor = Colors.orange;
          }

          return DataRow(
            cells: [
              DataCell(Text(product.name)),
              DataCell(
                Container(
                  width: 200, // Fixed width
                  child: Text(
                    product.description,
                    overflow: TextOverflow.ellipsis, // Show ellipsis
                    maxLines: 2, // Show only 2 lines
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              DataCell(Text('${product.quantity}')),
              DataCell(Text(currencyFormat.format(product.price))),
              DataCell(Text(currencyFormat.format(totalValue))),
              DataCell(Text(
                status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
