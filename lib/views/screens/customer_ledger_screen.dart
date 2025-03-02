import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/customer_ledger_model.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/model/sales_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:intl/intl.dart';

class CustomerLedgerScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerLedgerScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  List<dynamic> allTransactions = []; // Will hold both sales and payments
  bool isLoading = true;
  double balance = 0.0;
  DateFormat dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch sales data - Modified to avoid index requirement
      final salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('customerId', isEqualTo: widget.customer.id)
          .get();

      // Convert to sales models
      List<SalesModel> purchases = salesSnapshot.docs.map((doc) {
        return SalesModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();

      // Sort purchases in app instead of in the query
      purchases.sort((a, b) => b.saleDate.compareTo(a.saleDate));

      // Fetch payment data - Modified to avoid index requirement
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('customerId', isEqualTo: widget.customer.id)
          .get();

      // Convert to payment models
      List<CustomerTransactionModel> payments =
          paymentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return CustomerTransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();

      // Sort payments in app instead of in the query
      payments.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      // Combine all transactions in one list
      allTransactions = [...purchases, ...payments];

      // Sort by date (newest first)
      allTransactions.sort((a, b) {
        Timestamp dateA = a is SalesModel ? a.saleDate : a.transactionDate;
        Timestamp dateB = b is SalesModel ? b.saleDate : b.transactionDate;
        return dateB.compareTo(dateA);
      });

      calculateBalance(purchases, payments);
    } catch (e) {
      print('Error fetching customer data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateBalance(
      List<SalesModel> purchases, List<CustomerTransactionModel> payments) {
    // Calculate total purchases
    double totalPurchases =
        purchases.fold(0, (sum, sale) => sum + sale.totalAmount);

    // Calculate total payments
    double totalPayments =
        payments.fold(0, (sum, payment) => sum + payment.amount);

    // Balance = what customer owes
    balance = totalPurchases - totalPayments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        title: Text(
          "${widget.customer.name} - Details",
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer info with balance
                  _buildCustomerCard(),

                  // Transaction list header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Transaction History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${allTransactions.length} Items",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of all transactions
                  allTransactions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allTransactions.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final item = allTransactions[index];
                            if (item is SalesModel) {
                              return _buildPurchaseCard(item);
                            } else if (item is CustomerTransactionModel) {
                              return _buildPaymentCard(item);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      color: AppColors.primaryColor.withOpacity(0.05),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  widget.customer.name.isNotEmpty
                      ? widget.customer.name[0].toUpperCase()
                      : "C",
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Customer details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.customer.phone,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.customer.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.customer.email,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Balance section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balance > 0
                          ? "Customer owes you"
                          : balance < 0
                              ? "You owe customer"
                              : "No pending balance",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                "₹${balance.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: balance > 0
                      ? Colors.red
                      : balance < 0
                          ? Colors.green
                          : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(SalesModel sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Purchase",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateFormat.format(sale.saleDate.toDate()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const Divider(),

            // Product details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Qty: ${sale.quantity}",
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        children: [
                          Text(
                            "Invoice: ${sale.id.substring(0, min(sale.id.length, 6))}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Payment: ${sale.paymentMethod}",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount - Keep some minimum width
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${sale.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amount Due",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(CustomerTransactionModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.payment, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Payment Received",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateFormat.format(payment.transactionDate.toDate()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const Divider(),

            // Payment details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Reference: ${payment.reference}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Paid via ${payment.paymentMethod}",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${payment.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amount Paid",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No transactions found",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "All purchases and payments will appear here",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to safely get substring
  int min(int a, int b) {
    return a < b ? a : b;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
