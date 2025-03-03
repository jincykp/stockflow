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
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/model/sales_model.dart';
import 'package:stockflow/model/customer_ledger_model.dart';
import 'package:intl/intl.dart';

class CustomerLedgerExport {
  final CustomerModel customer;
  final List<dynamic> transactions; // Combined list of sales and payments
  final double balance;
  final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

  CustomerLedgerExport({
    required this.customer,
    required this.transactions,
    required this.balance,
  });

  // PDF export method
  Future<void> downloadPdf(BuildContext context) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            build: (pw.Context context) {
              return [
                _buildPdfHeader(),
                _buildPdfCustomerInfo(),
                _buildPdfTransactionsTable(),
              ];
            },
          ),
        );

        // Save the file in the Downloads folder
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        final filePath = '${directory!.path}/${customer.name}_ledger.pdf';
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

  // Excel export method
  Future<void> downloadExcel(BuildContext context) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        // Create a new Excel document
        final excel = Excel.createExcel();

        // Use the default sheet or create a new one
        final Sheet customerSheet = excel['Customer Ledger'];

        // Add customer information
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
            .value = TextCellValue('Customer Ledger Report');

        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
            .value = TextCellValue('Name:');
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
            .value = TextCellValue(customer.name);

        if (customer.phone.isNotEmpty) {
          customerSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
              .value = TextCellValue('Phone:');
          customerSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
              .value = TextCellValue(customer.phone);
        }

        if (customer.email.isNotEmpty) {
          customerSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
              .value = TextCellValue('Email:');
          customerSheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
              .value = TextCellValue(customer.email);
        }

        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
            .value = TextCellValue('Balance:');
        customerSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value =
            TextCellValue('₹${balance.abs().toStringAsFixed(2)}' +
                (balance > 0
                    ? ' (Customer owes)'
                    : balance < 0
                        ? ' (You owe)'
                        : ' (No balance)'));

        // Add a blank row
        int rowIndex = 6;

        // Add headers for transactions
        final List<String> headers = [
          "Date",
          "Type",
          "Description",
          "Amount",
          "Payment Method",
          "Reference"
        ];

        for (var i = 0; i < headers.length; i++) {
          customerSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: i, rowIndex: rowIndex))
              .value = TextCellValue(headers[i]);
        }

        rowIndex++;

        // Add transaction data
        for (var transaction in transactions) {
          List<String> rowData = [];

          if (transaction is SalesModel) {
            rowData = [
              dateFormat.format(transaction.saleDate.toDate()),
              'Purchase',
              transaction.productName,
              '₹${transaction.totalAmount.toStringAsFixed(2)}',
              transaction.paymentMethod,
              transaction.id.substring(0, min(transaction.id.length, 8)),
            ];
          } else if (transaction is CustomerTransactionModel) {
            rowData = [
              dateFormat.format(transaction.transactionDate.toDate()),
              'Payment',
              transaction.description,
              '₹${transaction.amount.toStringAsFixed(2)}',
              transaction.paymentMethod,
              transaction.reference,
            ];
          }

          for (var j = 0; j < rowData.length; j++) {
            customerSheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: j, rowIndex: rowIndex))
                .value = TextCellValue(rowData[j]);
          }

          rowIndex++;
        }

        // Set column widths for better readability
        for (var i = 0; i < headers.length; i++) {
          customerSheet.setColumnWidth(i, 20);
        }

        // Get directory for saving the file
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        final filePath = '${directory!.path}/${customer.name}_ledger.xlsx';
        final file = File(filePath);

        // Save the Excel file
        await file.writeAsBytes(excel.encode()!);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.successColor,
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

  // Email customer ledger report
  Future<void> sendEmail(BuildContext context) async {
    try {
      // First, create both PDF and Excel files to attach
      if (await _requestStoragePermission()) {
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        // Generate PDF report
        final pdfFilePath = '${directory!.path}/${customer.name}_ledger.pdf';
        await _generatePdfFile(pdfFilePath);

        // Generate Excel report
        final excelFilePath = '${directory.path}/${customer.name}_ledger.xlsx';
        await _generateExcelFile(excelFilePath);

        // Create email content as plain text
        String emailBody = 'Customer Ledger Report - ${customer.name}\n\n';
        emailBody += 'Balance: ₹${balance.abs().toStringAsFixed(2)}';
        emailBody += balance > 0
            ? ' (Customer owes)'
            : balance < 0
                ? ' (You owe)'
                : ' (No balance)';
        emailBody += '\n\nTransactions:\n';
        emailBody += 'Date | Type | Description | Amount | Payment Method\n';
        emailBody += '------------------------------------------------\n';

        // Add transactions to plain text
        for (var transaction in transactions) {
          if (transaction is SalesModel) {
            emailBody +=
                '${dateFormat.format(transaction.saleDate.toDate())} | Purchase | ${transaction.productName} | ₹${transaction.totalAmount.toStringAsFixed(2)} | ${transaction.paymentMethod}\n';
          } else if (transaction is CustomerTransactionModel) {
            emailBody +=
                '${dateFormat.format(transaction.transactionDate.toDate())} | Payment | ${transaction.description} | ₹${transaction.amount.toStringAsFixed(2)} | ${transaction.paymentMethod}\n';
          }
        }

        emailBody += '\nPlease find attached PDF and Excel reports.';

        // Configure email
        final Email email = Email(
          subject: 'Customer Ledger Report - ${customer.name}',
          body: emailBody,
          recipients: customer.email.isNotEmpty ? [customer.email] : [],
          attachmentPaths: [pdfFilePath, excelFilePath],
          isHTML: false,
        );

        // Launch email app
        await FlutterEmailSender.send(email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.successColor,
              content: Text("Email prepared with ledger report attachments")),
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

  // Generate PDF for printing
  Future<void> printLedgerReport(BuildContext context) async {
    try {
      // Create the PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              _buildPdfHeader(),
              _buildPdfCustomerInfo(),
              _buildPdfTransactionsTable(),
            ];
          },
        ),
      );

      // Print the document
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${customer.name} - Ledger Report',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successColor,
          content: Text("Printing ledger report..."),
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

  // Helper methods for PDF generation
  pw.Widget _buildPdfHeader() {
    return pw.Header(
      level: 0,
      child: pw.Text(
        "Customer Ledger Report",
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPdfCustomerInfo() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      margin: pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Customer: ${customer.name}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (customer.phone.isNotEmpty) pw.Text("Phone: ${customer.phone}"),
          if (customer.email.isNotEmpty) pw.Text("Email: ${customer.email}"),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Current Balance:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                "₹${balance.abs().toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: balance > 0
                      ? PdfColors.red
                      : balance < 0
                          ? PdfColors.green
                          : PdfColors.grey,
                ),
              ),
            ],
          ),
          pw.Text(
            balance > 0
                ? "Customer owes you"
                : balance < 0
                    ? "You owe customer"
                    : "No pending balance",
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTransactionsTable() {
    // Prepare data for the table
    List<List<String>> tableData = [];

    for (var transaction in transactions) {
      if (transaction is SalesModel) {
        tableData.add([
          dateFormat.format(transaction.saleDate.toDate()),
          'Purchase',
          transaction.productName,
          '₹${transaction.totalAmount.toStringAsFixed(2)}',
          transaction.paymentMethod,
          transaction.id.substring(0, min(transaction.id.length, 8)),
        ]);
      } else if (transaction is CustomerTransactionModel) {
        tableData.add([
          dateFormat.format(transaction.transactionDate.toDate()),
          'Payment',
          transaction.description,
          '₹${transaction.amount.toStringAsFixed(2)}',
          transaction.paymentMethod,
          transaction.reference,
        ]);
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Transaction History",
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: [
            'Date',
            'Type',
            'Description',
            'Amount',
            'Payment Method',
            'Reference'
          ],
          data: tableData,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          border: pw.TableBorder.all(),
          cellAlignment: pw.Alignment.center,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
          },
        ),
      ],
    );
  }

  // Helper method to generate PDF for email
  Future<void> _generatePdfFile(String filePath) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              _buildPdfHeader(),
              _buildPdfCustomerInfo(),
              _buildPdfTransactionsTable(),
            ];
          },
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error generating PDF for email: $e");
      throw e;
    }
  }

  // Helper method to generate Excel for email
  Future<void> _generateExcelFile(String filePath) async {
    try {
      // Create a new Excel document
      final excel = Excel.createExcel();

      // Use the default sheet or create a new one
      final Sheet customerSheet = excel['Customer Ledger'];

      // Add customer information
      customerSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue('Customer Ledger Report');

      customerSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = TextCellValue('Name:');
      customerSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = TextCellValue(customer.name);

      if (customer.phone.isNotEmpty) {
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
            .value = TextCellValue('Phone:');
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
            .value = TextCellValue(customer.phone);
      }

      if (customer.email.isNotEmpty) {
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
            .value = TextCellValue('Email:');
        customerSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
            .value = TextCellValue(customer.email);
      }

      customerSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
          .value = TextCellValue('Balance:');
      customerSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value =
          TextCellValue('₹${balance.abs().toStringAsFixed(2)}' +
              (balance > 0
                  ? ' (Customer owes)'
                  : balance < 0
                      ? ' (You owe)'
                      : ' (No balance)'));

      // Add a blank row
      int rowIndex = 6;

      // Add headers for transactions
      final List<String> headers = [
        "Date",
        "Type",
        "Description",
        "Amount",
        "Payment Method",
        "Reference"
      ];

      for (var i = 0; i < headers.length; i++) {
        customerSheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
            .value = TextCellValue(headers[i]);
      }

      rowIndex++;

      // Add transaction data
      for (var transaction in transactions) {
        List<String> rowData = [];

        if (transaction is SalesModel) {
          rowData = [
            dateFormat.format(transaction.saleDate.toDate()),
            'Purchase',
            transaction.productName,
            '₹${transaction.totalAmount.toStringAsFixed(2)}',
            transaction.paymentMethod,
            transaction.id.substring(0, min(transaction.id.length, 8)),
          ];
        } else if (transaction is CustomerTransactionModel) {
          rowData = [
            dateFormat.format(transaction.transactionDate.toDate()),
            'Payment',
            transaction.description,
            '₹${transaction.amount.toStringAsFixed(2)}',
            transaction.paymentMethod,
            transaction.reference,
          ];
        }

        for (var j = 0; j < rowData.length; j++) {
          customerSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: j, rowIndex: rowIndex))
              .value = TextCellValue(rowData[j]);
        }

        rowIndex++;
      }

      // Set column widths for better readability
      for (var i = 0; i < headers.length; i++) {
        customerSheet.setColumnWidth(i, 20);
      }

      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
    } catch (e) {
      print("Error generating Excel for email: $e");
      throw e;
    }
  }

  // Permission request helper method
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  // Helper function to safely get substring
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
