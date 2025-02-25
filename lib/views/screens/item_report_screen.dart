// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:stockflow/model/sales_model.dart';
// import 'package:stockflow/viewmodel/sales_provider.dart';
// import 'package:stockflow/viewmodel/product_provider.dart';
// import 'package:stockflow/views/widgets/custom_appbar.dart';
// import 'package:stockflow/views/widgets/loading_widget.dart';

// class ItemReportsScreen extends StatefulWidget {
//   const ItemReportsScreen({super.key});

//   @override
//   State<ItemReportsScreen> createState() => _ItemReportsScreenState();
// }

// class _ItemReportsScreenState extends State<ItemReportsScreen> {
//   DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime _endDate = DateTime.now();
//   String? _selectedProductId;

//   @override
//   void initState() {
//     super.initState();
    
//     // Fetch latest data when the screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final salesProvider = Provider.of<SalesProvider>(context, listen: false);
//       final productProvider = Provider.of<ProductProvider>(context, listen: false);
//       final userId = Provider.of<UserProvider>(context, listen: false).user?.uid ?? '';
      
//       salesProvider.fetchSales(userId);
//       productProvider.fetchProducts(userId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Item Reports"),
//       body: Consumer2<SalesProvider, ProductProvider>(
//         builder: (context, salesProvider, productProvider, child) {
//           if (salesProvider.isLoading || productProvider.isLoading) {
//             return const LoadingWidget();
//           }

//           if (salesProvider.errorMessage.isNotEmpty || productProvider.errorMessage.isNotEmpty) {
//             return Center(
//               child: Text(
//                 salesProvider.errorMessage.isNotEmpty 
//                     ? salesProvider.errorMessage 
//                     : productProvider.errorMessage,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           // Get filtered sales by date range
//           final filteredSales = salesProvider.getSalesByDateRange(_startDate, _endDate);
          
//           // Get product-wise sales data
//           final productSalesMap = _getProductSalesData(filteredSales);
          
//           return Column(
//             children: [
//               _buildFilterSection(productProvider),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: _selectedProductId == null
//                     ? _buildAllProductsReport(productSalesMap, productProvider)
//                     : _buildSingleProductReport(
//                         _selectedProductId!, 
//                         productSalesMap, 
//                         productProvider, 
//                         filteredSales
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilterSection(ProductProvider productProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Filter Report',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Start Date'),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: () => _selectDate(true),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(DateFormat('dd/MM/yyyy').format(_startDate)),
//                             const Icon(Icons.calendar_today),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('End Date'),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: () => _selectDate(false),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(DateFormat('dd/MM/yyyy').format(_endDate)),
//                             const Icon(Icons.calendar_today),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Select Product'),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String?>(
//                     isExpanded: true,
//                     value: _selectedProductId,
//                     hint: const Text('All Products'),
//                     items: [
//                       const DropdownMenuItem<String?>(
//                         value: null,
//                         child: Text('All Products'),
//                       ),
//                       ...productProvider.products.map((product) {
//                         return DropdownMenuItem<String?>(
//                           value: product.id,
//                           child: Text(product.name),
//                         );
//                       }).toList(),
//                     ],
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedProductId = value;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllProductsReport(
//     Map<String, Map<String, dynamic>> productSalesMap,
//     ProductProvider productProvider
//   ) {
//     final products = productProvider.products;
    
//     // Sort products by sales amount (descending)
//     final sortedProductIds = productSalesMap.keys.toList()
//       ..sort((a, b) => (productSalesMap[b]?['totalAmount'] ?? 0.0)
//           .compareTo(productSalesMap[a]?['totalAmount'] ?? 0.0));
    
//     // Calculate total sales
//     final totalSalesAmount = productSalesMap.values
//         .fold(0.0, (sum, data) => sum + (data['totalAmount'] as double));
    
//     return Column(
//       children: [
//         // Summary card
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.blue.withOpacity(0.3)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Items Sales Summary',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Total Sales: Rs. ${totalSalesAmount.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   'Products Sold: ${productSalesMap.length} of ${products.length}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   'Date Range: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 16),
        
//         // Products List
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Text(
//                 'Products by Sales',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 8),
        
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: sortedProductIds.length + (sortedProductIds.length < products.length ? 1 : 0),
//             itemBuilder: (context, index) {
//               // First show products with sales
//               if (index < sortedProductIds.length) {
//                 final productId = sortedProductIds[index];
//                 final salesData = productSalesMap[productId]!;
//                 final productName = salesData['productName'] as String;
//                 final totalQuantity = salesData['totalQuantity'] as int;
//                 final totalAmount = salesData['totalAmount'] as double;
                
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: ListTile(
//                     title: Text(
//                       productName,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text('Sold: $totalQuantity units'),
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Rs. ${totalAmount.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           '${((totalAmount / totalSalesAmount) * 100).toStringAsFixed(1)}%',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       setState(() {
//                         _selectedProductId = productId;
//                       });
//                     },
//                   ),
//                 );
//               } else {
//                 // Then show products with no sales (if any)
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   color: Colors.grey[100],
//                   child: ExpansionTile(
//                     title: const Text(
//                       'Products with No Sales',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     children: products
//                         .where((product) => !productSalesMap.containsKey(product.id))
//                         .map((product) {
//                       return ListTile(
//                         title: Text(product.name),
//                         subtitle: Text('Current Stock: ${product.quantity}'),
//                         trailing: Text('Rs. ${product.price.toStringAsFixed(2)}'),
//                         onTap: () {
//                           setState(() {
//                             _selectedProductId = product.id;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSingleProductReport(
//     String productId,
//     Map<String, Map<String, dynamic>> productSalesMap,
//     ProductProvider productProvider,
//     List<SalesModel> filteredSales
//   ) {
//     // Get the product
//     final product = productProvider.products.firstWhere(
//       (product) => product.id == productId,
//       orElse: () => throw Exception('Product not found'),
//     );
    
//     // Get sales for this product
//     final productSales = filteredSales
//         .where((sale) => sale.productId == productId)
//         .toList();
    
//     // Sort by date (most recent first)
//     productSales.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    
//     // Get sales data summary
//     final salesData = productSalesMap[productId];
//     final totalQuantity = salesData?['totalQuantity'] as int? ?? 0;
//     final totalAmount = salesData?['totalAmount'] as double? ?? 0.0;
    
//     // Get unique customers who bought this product
//     final uniqueCustomers = productSales
//         .map((sale) => sale.customerId)
//         .toSet()
//         .length;
    
//     return Column(
//       children: [
//         // Product info and summary
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Card(
//             elevation: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           product.name,
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         onPressed: () {
//                           setState(() {
//                             _selectedProductId = null;
//                           });