import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:printing/printing.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:intl/intl.dart';

class ItemExportFiles {
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  // PDF export method
  Future<void> downloadPdf(
      BuildContext context, List<ProductModel> products) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Inventory Report",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(
                      "Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}"),
                  pw.SizedBox(height: 10),
                  _buildSummaryTable(products),
                  pw.SizedBox(height: 15),
                  pw.Text("Detailed Inventory",
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  _buildProductTable(products),
                ],
              );
            },
          ),
        );

        // Save the file in the Downloads folder
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        final filePath = '${directory!.path}/inventory_report.pdf';
        final file = File(filePath);

        await file.writeAsBytes(await pdf.save());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.successColor,
              content: Text("PDF saved at: $filePath"),
              duration: Duration(seconds: 3)),
        );

        print("PDF saved at: $filePath");
      } else {
        print("Permission denied! Cannot save PDF.");
      }
    } catch (e) {
      print("Error saving PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting to PDF: $e"),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }

  // Helper method to build summary table for PDF
  pw.Widget _buildSummaryTable(List<ProductModel> products) {
    // Calculate summary statistics
    final totalProducts = products.length;
    final totalQuantity =
        products.fold<int>(0, (sum, product) => sum + product.quantity);
    final totalValue = products.fold<double>(
        0, (sum, product) => sum + (product.price * product.quantity));
    final lowStock = products.where((p) => p.quantity < 10).length;

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Summary",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _buildSummaryRow("Total Products", "$totalProducts items"),
          _buildSummaryRow("Total Quantity", "$totalQuantity units"),
          _buildSummaryRow("Total Inventory Value",
              currencyFormat.format(totalValue).toString()),
          _buildSummaryRow("Low Stock Items", "$lowStock items"),
        ],
      ),
    );
  }

  // Helper method to build summary row for PDF
  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper method to build product table for PDF
  pw.Widget _buildProductTable(List<ProductModel> products) {
    return pw.Table.fromTextArray(
      headers: [
        "Name",
        "Description",
        "Quantity",
        "Price",
        "Total Value",
        "Status"
      ],
      data: products.map((product) {
        final totalValue = product.price * product.quantity;
        String status = 'In Stock';

        if (product.quantity <= 0) {
          status = 'Out of Stock';
        } else if (product.quantity < 10) {
          status = 'Low Stock';
        }

        return [
          product.name,
          product.description,
          product.quantity.toString(),
          currencyFormat.format(product.price).toString(),
          currencyFormat.format(totalValue).toString(),
          status
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.center,
      cellAlignments: {
        0: pw.Alignment.centerLeft, // Name
        1: pw.Alignment.centerLeft, // Description
      },
    );
  }

  // Excel export method
  Future<void> downloadExcel(
      BuildContext context, List<ProductModel> products) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        // Create a new Excel document
        final excel = Excel.createExcel();

        // Create Summary Sheet
        final Sheet summarySheet = excel['Summary'];
        _addSummaryToExcel(summarySheet, products);

        // Create Detailed Inventory Sheet
        final Sheet detailSheet = excel['Detailed Inventory'];
        _addProductDetailsToExcel(detailSheet, products);

        // Get directory for saving the file
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        final filePath = '${directory!.path}/inventory_report.xlsx';
        final file = File(filePath);

        // Save the Excel file
        await file.writeAsBytes(excel.encode()!);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Excel file saved at: $filePath"),
              duration: Duration(seconds: 3)),
        );

        print("Excel file saved at: $filePath");
      } else {
        print("Permission denied! Cannot save Excel file.");
      }
    } catch (e) {
      print("Error saving Excel file: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error exporting to Excel: $e"),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }

  // Helper method to add summary data to Excel
  void _addSummaryToExcel(Sheet sheet, List<ProductModel> products) {
    // Calculate summary statistics
    final totalProducts = products.length;
    final totalQuantity =
        products.fold<int>(0, (sum, product) => sum + product.quantity);
    final totalValue = products.fold<double>(
        0, (sum, product) => sum + (product.price * product.quantity));
    final lowStock = products.where((p) => p.quantity < 10).length;

    // Add title
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue("Inventory Summary Report");

    // Add generation date
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue(
            "Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}");

    // Add headers
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value =
        TextCellValue("Metric");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value =
        TextCellValue("Value");

    // Add data
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4)).value =
        TextCellValue("Total Products");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value =
        TextCellValue("$totalProducts items");

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5)).value =
        TextCellValue("Total Quantity");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5)).value =
        TextCellValue("$totalQuantity units");

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 6)).value =
        TextCellValue("Total Inventory Value");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 6)).value =
        TextCellValue(currencyFormat.format(totalValue));

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 7)).value =
        TextCellValue("Low Stock Items");
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 7)).value =
        TextCellValue("$lowStock items");

    // Set column widths for better readability
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 20);
  }

  // Helper method to add product details to Excel
  void _addProductDetailsToExcel(Sheet sheet, List<ProductModel> products) {
    // Add headers
    final List<String> headers = [
      "Name",
      "Description",
      "Quantity",
      "Price",
      "Total Value",
      "Status"
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
    }

    // Add data rows
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final totalValue = product.price * product.quantity;

      String status = 'In Stock';
      if (product.quantity <= 0) {
        status = 'Out of Stock';
      } else if (product.quantity < 10) {
        status = 'Low Stock';
      }

      // Name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(product.name);

      // Description
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(product.description);

      // Quantity
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(product.quantity.toString());

      // Price
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(currencyFormat.format(product.price));

      // Total Value
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(currencyFormat.format(totalValue));

      // Status
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue(status);
    }

    // Set column widths for better readability
    sheet.setColumnWidth(0, 20); // Name
    sheet.setColumnWidth(1, 40); // Description
    sheet.setColumnWidth(2, 15); // Quantity
    sheet.setColumnWidth(3, 15); // Price
    sheet.setColumnWidth(4, 15); // Total Value
    sheet.setColumnWidth(5, 15); // Status
  }

  // Email inventory report method
  Future<void> sendEmail(
      BuildContext context, List<ProductModel> products) async {
    try {
      // First, create both PDF and Excel files to attach
      if (await _requestStoragePermission()) {
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        // Generate PDF report
        final pdfFilePath = '${directory!.path}/inventory_report.pdf';
        await _generatePdfFile(pdfFilePath, products);

        // Generate Excel report
        final excelFilePath = '${directory.path}/inventory_report.xlsx';
        await _generateExcelFile(excelFilePath, products);

        // Create email content as plain text
        String emailBody = 'Inventory Report\n\n';

        // Add summary information
        final totalProducts = products.length;
        final totalQuantity =
            products.fold<int>(0, (sum, product) => sum + product.quantity);
        final totalValue = products.fold<double>(
            0, (sum, product) => sum + (product.price * product.quantity));
        final lowStock = products.where((p) => p.quantity < 10).length;

        emailBody += 'Summary:\n';
        emailBody += '- Total Products: $totalProducts items\n';
        emailBody += '- Total Quantity: $totalQuantity units\n';
        emailBody +=
            '- Total Inventory Value: ${currencyFormat.format(totalValue)}\n';
        emailBody += '- Low Stock Items: $lowStock items\n\n';

        emailBody += 'Product details are available in the attached files.\n';
        emailBody += '\nPlease find attached PDF and Excel reports.';

        // Configure email
        final Email email = Email(
          subject: 'Inventory Report',
          body: emailBody,
          recipients: [], // Will be filled in by user in email app
          attachmentPaths: [pdfFilePath, excelFilePath],
          isHTML: false,
        );

        // Launch email app
        await FlutterEmailSender.send(email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Email prepared with inventory report attachments")),
        );
      } else {
        print("Permission denied! Cannot create attachments for email.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cannot send email: Storage permission denied"),
            backgroundColor: AppColors.warningColor,
          ),
        );
      }
    } catch (e) {
      print("Error sending email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending email: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to generate PDF for email
  Future<void> _generatePdfFile(
      String filePath, List<ProductModel> products) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Inventory Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                    "Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}"),
                pw.SizedBox(height: 10),
                _buildSummaryTable(products),
                pw.SizedBox(height: 15),
                pw.Text("Detailed Inventory",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildProductTable(products),
              ],
            );
          },
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error generating PDF for email: $e");
      // Create a simpler PDF on error
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Inventory Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ["Name", "Quantity", "Price", "Total Value"],
                  data: products.map((product) {
                    final totalValue = product.price * product.quantity;
                    return [
                      product.name,
                      product.quantity.toString(),
                      currencyFormat.format(product.price).toString(),
                      currencyFormat.format(totalValue).toString(),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
    }
  }

  // Helper method to generate Excel for email
  Future<void> _generateExcelFile(
      String filePath, List<ProductModel> products) async {
    final excel = Excel.createExcel();

    // Create Summary Sheet
    final Sheet summarySheet = excel['Summary'];
    _addSummaryToExcel(summarySheet, products);

    // Create Detailed Inventory Sheet
    final Sheet detailSheet = excel['Detailed Inventory'];
    _addProductDetailsToExcel(detailSheet, products);

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
  }

  // Print inventory report method
  Future<void> printInventoryReport(
      BuildContext context, List<ProductModel> products) async {
    try {
      // Create the PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Inventory Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                    "Generated on ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}"),
                pw.SizedBox(height: 10),
                _buildSummaryTable(products),
                pw.SizedBox(height: 15),
                pw.Text("Detailed Inventory",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildProductTable(products),
              ],
            );
          },
        ),
      );

      // Print the document
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Inventory Report',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successColor,
          content: Text("Printing inventory report..."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error printing report: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error printing report: $e"),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }

  // Permission request helper method
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }
}
