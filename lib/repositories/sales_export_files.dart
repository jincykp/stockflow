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

class ExportFiles {
  // PDF export method
  Future<void> downloadPdf(
      BuildContext context, List<Map<String, String>> salesData) async {
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
                  pw.Text("Sales Report",
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Table.fromTextArray(
                    headers: ["Date", "Customer", "Product", "Total Amount"],
                    data: salesData
                        .map((sale) => [
                              sale['date'],
                              sale['customer'],
                              sale['product'],
                              sale['totalAmount']
                            ])
                        .toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
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

        final filePath = '${directory!.path}/sales_report.pdf';
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
  Future<void> downloadExcel(
      BuildContext context, List<Map<String, String>> salesData) async {
    try {
      // Request storage permission
      if (await _requestStoragePermission()) {
        // Create a new Excel document
        final excel = Excel.createExcel();

        // Use the default sheet or create a new one
        final Sheet sheet = excel['Sales Report'];

        // Add headers
        final List<String> headers = [
          "Date",
          "Customer",
          "Product",
          "Total Amount"
        ];
        for (var i = 0; i < headers.length; i++) {
          final cell = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = TextCellValue(headers[i]);

          // Create a cell style with proper color formatting
          // cell.cellStyle = CellStyle(
          //   bold: true,
          //   backgroundColorHex:
          //       HexColor.fromArgb(255, 204, 204, 204), // CCCCCC in RGB
          //   horizontalAlign: HorizontalAlign.Center,
          // );
        }

        // Add data rows
        for (var i = 0; i < salesData.length; i++) {
          final rowData = [
            salesData[i]['date'] ?? '',
            salesData[i]['customer'] ?? '',
            salesData[i]['product'] ?? '',
            salesData[i]['totalAmount'] ?? ''
          ];

          for (var j = 0; j < rowData.length; j++) {
            sheet
                .cell(
                    CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
                .value = TextCellValue(rowData[j]);
          }
        }

        // Set column widths for better readability
        for (var i = 0; i < headers.length; i++) {
          sheet.setColumnWidth(i, 20);
        }

        // Get directory for saving the file
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        final filePath = '${directory!.path}/sales_report.xlsx';
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

  // Email sales report method
  Future<void> sendEmail(
      BuildContext context, List<Map<String, String>> salesData) async {
    try {
      // First, create both PDF and Excel files to attach
      if (await _requestStoragePermission()) {
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory(); // Fallback
        }

        // Generate PDF report
        final pdfFilePath = '${directory!.path}/sales_report.pdf';
        await _generatePdfFile(pdfFilePath, salesData);

        // Generate Excel report
        final excelFilePath = '${directory.path}/sales_report.xlsx';
        await _generateExcelFile(excelFilePath, salesData);

        // Create email content as plain text instead of HTML
        String emailBody = 'Sales Report\n\n';
        emailBody += 'Date | Customer | Product | Total Amount\n';
        emailBody += '----------------------------------------\n';

        // Add rows to plain text
        for (var sale in salesData) {
          emailBody +=
              '${sale['date'] ?? ''} | ${sale['customer'] ?? ''} | ${sale['product'] ?? ''} | ${sale['totalAmount'] ?? ''}\n';
        }

        emailBody += '\nPlease find attached PDF and Excel reports.';

        // Configure email
        final Email email = Email(
          subject: 'Sales Report',
          body: emailBody,
          recipients: [], // Will be filled in by user in email app
          attachmentPaths: [pdfFilePath, excelFilePath],
          isHTML: false, // Changed to false for plain text
        );

        // Launch email app
        await FlutterEmailSender.send(email);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Email prepared with sales report attachments")),
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
      String filePath, List<Map<String, String>> salesData) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Sales Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ["Date", "Customer", "Product", "Total Amount"],
                  data: salesData
                      .map((sale) => [
                            sale['date'],
                            sale['customer'],
                            sale['product'],
                            sale['totalAmount']
                          ])
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error generating PDF for email: $e");
      // Fallback to a simpler PDF if there's an error
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Sales Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ["Date", "Customer", "Product", "Total Amount"],
                  data: salesData
                      .map((sale) => [
                            sale['date'],
                            sale['customer'],
                            sale['product'],
                            sale['totalAmount']
                          ])
                      .toList(),
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
      String filePath, List<Map<String, String>> salesData) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Sales Report'];

    // Add headers
    final List<String> headers = [
      "Date",
      "Customer",
      "Product",
      "Total Amount"
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
    }

    // Add data rows
    for (var i = 0; i < salesData.length; i++) {
      final rowData = [
        salesData[i]['date'] ?? '',
        salesData[i]['customer'] ?? '',
        salesData[i]['product'] ?? '',
        salesData[i]['totalAmount'] ?? ''
      ];

      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = TextCellValue(rowData[j]);
      }
    }

    // Set column widths
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);
  }

  // Permission request helper method
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> printSalesReport(
      BuildContext context, List<Map<String, String>> salesData) async {
    try {
      // Create the PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Sales Report",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ["Date", "Customer", "Product", "Total Amount"],
                  data: salesData
                      .map((sale) => [
                            sale['date'],
                            sale['customer'],
                            sale['product'],
                            sale['totalAmount']
                          ])
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            );
          },
        ),
      );

      // Print the document
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Sales Report',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successColor,
          content: Text("Printing sales report..."),
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
}
