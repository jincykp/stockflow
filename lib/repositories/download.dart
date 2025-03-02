// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:excel/excel.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:intl/intl.dart';
// import 'package:stockflow/model/sales_model.dart';
// import 'package:pdf/pdf.dart';

// import 'package:intl/intl.dart';

// class ReportExportService {
//   // Check and request storage permission
//   static Future<bool> _checkPermission(BuildContext context) async {
//     // Request storage permission
//     var status = await Permission.storage.status;

//     if (status.isDenied) {
//       // Show dialog explaining why we need permission
//       final shouldRequest = await showDialog<bool>(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Permission Required'),
//               content: const Text(
//                   'This app needs storage permission to save and share reports. Would you like to grant this permission?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Deny'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: const Text('Accept'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;

//       if (shouldRequest) {
//         status = await Permission.storage.request();
//       }
//     }

//     // If permission is permanently denied, open app settings
//     if (status.isPermanentlyDenied) {
//       final shouldOpenSettings = await showDialog<bool>(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Permission Denied'),
//               content: const Text(
//                   'Storage permission is permanently denied. Please open app settings and enable it manually.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: const Text('Open Settings'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;

//       if (shouldOpenSettings) {
//         await openAppSettings();
//       }
//       return false;
//     }

//     return status.isGranted;
//   }

//   // Generate PDF document
//   // static Future<pw.Document> _generatePdf(List<SalesModel> sales,
//   //     DateTime startDate, DateTime endDate, String paymentMethod) async {
//   //   final pdf = pw.Document();

//   //   // Calculate totals
//   //   final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
//   //   final totalItems = sales.fold(0, (sum, sale) => sum + sale.quantity);
//   //   final uniqueCustomers = sales.map((sale) => sale.customerId).toSet().length;

//   //   // Group sales by payment method
//   //   final paymentMethodSummary = <String, double>{};
//   //   for (final sale in sales) {
//   //     final method = sale.paymentMethod;
//   //     paymentMethodSummary[method] =
//   //         (paymentMethodSummary[method] ?? 0) + sale.totalAmount;
//   //   }

//   //   // Group sales by product
//   //   final productSummary = <String, Map<String, dynamic>>{};
//   //   for (final sale in sales) {
//   //     if (!productSummary.containsKey(sale.productId)) {
//   //       productSummary[sale.productId] = {
//   //         'name': sale.productName,
//   //         'quantity': 0,
//   //         'amount': 0.0,
//   //       };
//   //     }

//   //     productSummary[sale.productId]!['quantity'] =
//   //         (productSummary[sale.productId]!['quantity'] as int) + sale.quantity;
//   //     productSummary[sale.productId]!['amount'] =
//   //         (productSummary[sale.productId]!['amount'] as double) +
//   //             sale.totalAmount;
//   //   }

//   //   pdf.addPage(
//   //     pw.MultiPage(
//   //       pageFormat: PdfPageFormat.a4,
//   //       margin: const pw.EdgeInsets.all(32),
//   //       header: (pw.Context context) {
//   //         return pw.Column(
//   //           crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //           children: [
//   //             pw.Text(
//   //               'Sales Report',
//   //               style: pw.TextStyle(
//   //                 fontSize: 24,
//   //                 fontWeight: pw.FontWeight.bold,
//   //               ),
//   //             ),
//   //             pw.SizedBox(height: 8),
//   //             pw.Text(
//   //               'Period: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
//   //             ),
//   //             pw.Text(
//   //               'Payment Method: ${paymentMethod == 'All' ? 'All Methods' : paymentMethod}',
//   //             ),
//   //             pw.SizedBox(height: 8),
//   //             pw.Divider(),
//   //           ],
//   //         );
//   //       },
//   //       build: (pw.Context context) {
//   //         return [
//   //           // Summary section
//   //           pw.Container(
//   //             padding: const pw.EdgeInsets.all(10),
//   //             decoration: pw.BoxDecoration(
//   //               color: PdfColors.grey100,
//   //               borderRadius: pw.BorderRadius.circular(8),
//   //             ),
//   //             child: pw.Row(
//   //               mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
//   //               children: [
//   //                 _buildPdfSummaryItem(
//   //                     'Total Sales', 'Rs. ${totalSales.toStringAsFixed(2)}'),
//   //                 _buildPdfSummaryItem('Items Sold', totalItems.toString()),
//   //                 _buildPdfSummaryItem('Customers', uniqueCustomers.toString()),
//   //               ],
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 20),

//   //           // Payment Methods section
//   //           pw.Text(
//   //             'Payment Methods',
//   //             style: pw.TextStyle(
//   //               fontSize: 16,
//   //               fontWeight: pw.FontWeight.bold,
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 10),
//   //           _buildPdfTable(
//   //             ['Payment Method', 'Amount (Rs.)'],
//   //             paymentMethodSummary.entries
//   //                 .map((entry) => [
//   //                       entry.key,
//   //                       entry.value.toStringAsFixed(2),
//   //                     ])
//   //                 .toList(),
//   //           ),
//   //           pw.SizedBox(height: 20),

//   //           // Products section
//   //           pw.Text(
//   //             'Top Products',
//   //             style: pw.TextStyle(
//   //               fontSize: 16,
//   //               fontWeight: pw.FontWeight.bold,
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 10),
//   //           _buildPdfTable(
//   //             ['Product', 'Quantity', 'Amount (Rs.)'],
//   //             productSummary.values
//   //                 .map((product) => [
//   //                       product['name'] as String,
//   //                       (product['quantity'] as int).toString(),
//   //                       (product['amount'] as double).toStringAsFixed(2),
//   //                     ])
//   //                 .toList(),
//   //           ),
//   //           pw.SizedBox(height: 20),

//   //           // Sales list section
//   //           pw.Text(
//   //             'Sales List',
//   //             style: pw.TextStyle(
//   //               fontSize: 16,
//   //               fontWeight: pw.FontWeight.bold,
//   //             ),
//   //           ),
//   //           pw.SizedBox(height: 10),
//   //           _buildPdfTable(
//   //             ['Date', 'Product', 'Customer', 'Qty', 'Amount (Rs.)'],
//   //             sales
//   //                 .map((sale) => [
//   //                       DateFormat('dd/MM/yyyy').format(sale.saleDate.toDate()),
//   //                       sale.productName,
//   //                       sale.customerName,
//   //                       sale.quantity.toString(),
//   //                       sale.totalAmount.toStringAsFixed(2),
//   //                     ])
//   //                 .toList(),
//   //           ),
//   //         ];
//   //       },
//   //     ),
//   //   );

//   //   return pdf;
//   // }

//   // // Helper method to build PDF summary item
//   // static pw.Widget _buildPdfSummaryItem(String title, String value) {
//   //   return pw.Column(
//   //     children: [
//   //       pw.Text(
//   //         title,
//   //         style: pw.TextStyle(
//   //           fontSize: 12,
//   //           color: PdfColors.grey700,
//   //         ),
//   //       ),
//   //       pw.SizedBox(height: 4),
//   //       pw.Text(
//   //         value,
//   //         style: pw.TextStyle(
//   //           fontSize: 14,
//   //           fontWeight: pw.FontWeight.bold,
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // Helper method to build PDF table
//   static pw.Widget _buildPdfTable(
//       List<String> headers, List<List<String>> data) {
//     return pw.Table.fromTextArray(
//       border: null,
//       headerDecoration: const pw.BoxDecoration(
//         borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
//         color: PdfColors.grey300,
//       ),
//       headerHeight: 25,
//       cellHeight: 30,
//       headerStyle: pw.TextStyle(
//         fontWeight: pw.FontWeight.bold,
//       ),
//       cellAlignments: {
//         for (var i = 0; i < headers.length; i++)
//           i: headers[i].contains('Amount') || headers[i].contains('Qty')
//               ? pw.Alignment.centerRight
//               : pw.Alignment.centerLeft,
//       },
//       headers: headers,
//       data: data,
//     );
//   }

//   // Generate Excel file
//   static Future<Excel> _generateExcel(List<SalesModel> sales,
//       DateTime startDate, DateTime endDate, String paymentMethod) async {
//     final excel = Excel.createExcel();

//     // Delete the default sheet
//     if (excel.getDefaultSheet() != null) {
//       excel.delete(excel.getDefaultSheet()!);
//     }

//     // Create Sales sheet
//     final salesSheet = excel['Sales'];

//     // Add title and filters
//     salesSheet.cell(CellIndex.indexByString('A1')).value =
//         TextCellValue('Sales Report');
//     salesSheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
//         'Period: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}');
//     salesSheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
//         'Payment Method: ${paymentMethod == 'All' ? 'All Methods' : paymentMethod}');

//     // Add headers - row 5
//     final headers = [
//       'Date',
//       'Product',
//       'Customer',
//       'Payment Method',
//       'Quantity',
//       'Unit Price',
//       'Total Amount'
//     ];
//     for (var i = 0; i < headers.length; i++) {
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4))
//           .value = TextCellValue(headers[i]);
//     }

//     // Add data - starting from row 6
//     for (var i = 0; i < sales.length; i++) {
//       final sale = sales[i];
//       salesSheet
//               .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 5))
//               .value =
//           TextCellValue(
//               DateFormat('dd/MM/yyyy').format(sale.saleDate.toDate()));
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 5))
//           .value = TextCellValue(sale.productName);
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 5))
//           .value = TextCellValue(sale.customerName);
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 5))
//           .value = TextCellValue(sale.paymentMethod);
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 5))
//           .value = IntCellValue(sale.quantity);

//       // Calculate unit price
//       double unitPrice = sale.totalAmount / sale.quantity;
//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 5))
//           .value = DoubleCellValue(unitPrice);

//       salesSheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 5))
//           .value = DoubleCellValue(sale.totalAmount);
//     }

//     // Create Summary sheet
//     final summarySheet = excel['Summary'];

//     // Add payment method summary
//     summarySheet.cell(CellIndex.indexByString('A1')).value =
//         TextCellValue('Payment Methods Summary');
//     summarySheet.cell(CellIndex.indexByString('A2')).value =
//         TextCellValue('Method');
//     summarySheet.cell(CellIndex.indexByString('B2')).value =
//         TextCellValue('Amount (Rs.)');

//     // Group sales by payment method
//     final paymentMethodSummary = <String, double>{};
//     for (final sale in sales) {
//       final method = sale.paymentMethod;
//       paymentMethodSummary[method] =
//           (paymentMethodSummary[method] ?? 0) + sale.totalAmount;
//     }

//     var row = 3;
//     paymentMethodSummary.forEach((method, amount) {
//       summarySheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//           .value = TextCellValue(method);
//       summarySheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//           .value = DoubleCellValue(amount);
//       row++;
//     });

//     // Add product summary
//     row += 2;
//     summarySheet
//         .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue('Product Summary');
//     row++;
//     summarySheet
//         .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//         .value = TextCellValue('Product');
//     summarySheet
//         .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//         .value = TextCellValue('Quantity');
//     summarySheet
//         .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
//         .value = TextCellValue('Amount (Rs.)');
//     row++;

//     // Group sales by product
//     final productSummary = <String, Map<String, dynamic>>{};
//     for (final sale in sales) {
//       if (!productSummary.containsKey(sale.productId)) {
//         productSummary[sale.productId] = {
//           'name': sale.productName,
//           'quantity': 0,
//           'amount': 0.0,
//         };
//       }

//       productSummary[sale.productId]!['quantity'] =
//           (productSummary[sale.productId]!['quantity'] as int) + sale.quantity;
//       productSummary[sale.productId]!['amount'] =
//           (productSummary[sale.productId]!['amount'] as double) +
//               sale.totalAmount;
//     }

//     productSummary.forEach((_, product) {
//       summarySheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
//           .value = TextCellValue(product['name'] as String);
//       summarySheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
//           .value = IntCellValue(product['quantity'] as int);
//       summarySheet
//           .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
//           .value = DoubleCellValue(product['amount'] as double);
//       row++;
//     });

//     return excel;
//   }

//   // Print report
//   // static Future<void> printReport(BuildContext context, List<SalesModel> sales,
//   //     DateTime startDate, DateTime endDate, String paymentMethod) async {
//   //   try {
//   //     final pdf = await _generatePdf(sales, startDate, endDate, paymentMethod);

//   //     await Printing.layoutPdf(
//   //       onLayout: (PdfPageFormat format) async => pdf.save(),
//   //       name: 'Sales Report ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
//   //     );

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Print job sent successfully')),
//   //     );
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error printing report: ${e.toString()}')),
//   //     );
//   //   }
//   // }

//   // Export to Excel
//   static Future<void> exportToExcel(
//       BuildContext context,
//       List<SalesModel> sales,
//       DateTime startDate,
//       DateTime endDate,
//       String paymentMethod) async {
//     final hasPermission = await _checkPermission(context);
//     if (!hasPermission) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Permission denied. Cannot export to Excel')),
//       );
//       return;
//     }

//     try {
//       final excel =
//           await _generateExcel(sales, startDate, endDate, paymentMethod);

//       // Get directory for saving the file
//       final directory = await getExternalStorageDirectory() ??
//           await getApplicationDocumentsDirectory();
//       final fileName =
//           'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
//       final filePath = '${directory.path}/$fileName';

//       // Save the Excel file
//       final file = File(filePath);
//       final bytes = excel.encode();
//       if (bytes != null) {
//         await file.writeAsBytes(bytes);

//         // Show success message and share option
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Export Successful'),
//             content: Text('Excel file saved to:\n$filePath'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Share.shareXFiles([XFile(filePath)], text: 'Sales Report');
//                 },
//                 child: const Text('Share'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         throw Exception('Failed to encode Excel file');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error exporting to Excel: ${e.toString()}')),
//       );
//     }
//   }

//   // Export to PDF
//   // static Future<void> exportToPDF(BuildContext context, List<SalesModel> sales,
//   //     DateTime startDate, DateTime endDate, String paymentMethod) async {
//   //   final hasPermission = await _checkPermission(context);
//   //   if (!hasPermission) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //           content: Text('Permission denied. Cannot export to PDF')),
//   //     );
//   //     return;
//   //   }

//   //   try {
//   //     final pdf = await _generatePdf(sales, startDate, endDate, paymentMethod);

//   //     // Get directory for saving the file
//   //     final directory = await getExternalStorageDirectory() ??
//   //         await getApplicationDocumentsDirectory();
//   //     final fileName =
//   //         'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
//   //     final filePath = '${directory.path}/$fileName';

//   //     // Save the PDF file
//   //     final file = File(filePath);
//   //     await file.writeAsBytes(await pdf.save());

//   //     // Show success message and share option
//   //     showDialog(
//   //       context: context,
//   //       builder: (context) => AlertDialog(
//   //         title: const Text('Export Successful'),
//   //         content: Text('PDF file saved to:\n$filePath'),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () => Navigator.pop(context),
//   //             child: const Text('OK'),
//   //           ),
//   //           TextButton(
//   //             onPressed: () {
//   //               Navigator.pop(context);
//   //               Share.shareXFiles([XFile(filePath)], text: 'Sales Report');
//   //             },
//   //             child: const Text('Share'),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error exporting to PDF: ${e.toString()}')),
//   //     );
//   //   }
//   // }

//   // Send report via email
//   static Future<void> sendReportByEmail(
//       BuildContext context,
//       List<SalesModel> sales,
//       DateTime startDate,
//       DateTime endDate,
//       String paymentMethod) async {
//     final hasPermission = await _checkPermission(context);
//     if (!hasPermission) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permission denied. Cannot send email')),
//       );
//       return;
//     }

//     try {
//       // Generate both PDF and Excel files
//       // final pdf = await _generatePdf(sales, startDate, endDate, paymentMethod);
//       final excel =
//           await _generateExcel(sales, startDate, endDate, paymentMethod);

//       // Get directory for saving the files
//       final directory = await getExternalStorageDirectory() ??
//           await getApplicationDocumentsDirectory();
//       final pdfFileName =
//           'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
//       final excelFileName =
//           'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
//       final pdfFilePath = '${directory.path}/$pdfFileName';
//       final excelFilePath = '${directory.path}/$excelFileName';

//       // Save the files
//       final pdfFile = File(pdfFilePath);
//       // await pdfFile.writeAsBytes(await pdf.save());

//       final excelFile = File(excelFilePath);
//       final bytes = excel.encode();
//       if (bytes != null) {
//         await excelFile.writeAsBytes(bytes);
//       } else {
//         throw Exception('Failed to encode Excel file');
//       }

//       // Compose email
//       final dateRange =
//           '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';
//       final subject = 'Sales Report: $dateRange';
//       final body =
//           'Please find attached the sales report for the period $dateRange.\n\n'
//           'Payment Method: ${paymentMethod == 'All' ? 'All Methods' : paymentMethod}\n\n'
//           'This report was generated on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}.';

//       // Ask for email address
//       final TextEditingController emailController = TextEditingController();
//       final entered = await showDialog<bool>(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Send Email'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text('Enter email address:'),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       hintText: 'example@email.com',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: const Text('Send'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;

//       if (entered && emailController.text.isNotEmpty) {
//         final email = emailController.text.trim();

//         // Share files with email clients
//         await Share.shareXFiles(
//           [XFile(pdfFilePath), XFile(excelFilePath)],
//           subject: subject,
//           text: body,
//         );

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Email prepared with attachments for $email')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending email: ${e.toString()}')),
//       );
//     }
//   }
// }
