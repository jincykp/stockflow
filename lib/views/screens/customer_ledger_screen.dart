import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/customer_ledger_model.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/model/sales_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:intl/intl.dart'; // Make sure to add this dependency

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
  List<CustomerTransactionModel> transactions = [];
  bool isLoading = true;
  double balance = 0.0;
  DateFormat dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      // First, get all sales for this customer
      final salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('saleDate', descending: true)
          .get();

      List<CustomerTransactionModel> salesTransactions =
          salesSnapshot.docs.map((doc) {
        final salesModel = SalesModel.fromMap({
          ...doc.data(),
          'id': doc.id,
        });
        return CustomerTransactionModel.fromSalesModel(salesModel);
      }).toList();

      // Then, get all payments for this customer
      final paymentsSnapshot = await FirebaseFirestore.instance
          .collection('payments') // You may need to create this collection
          .where('customerId', isEqualTo: widget.customer.id)
          .orderBy('paymentDate', descending: true)
          .get();

      List<CustomerTransactionModel> paymentTransactions =
          paymentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return CustomerTransactionModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();

      // Combine and sort all transactions by date
      transactions = [...salesTransactions, ...paymentTransactions];
      transactions.sort((a, b) =>
          b.transactionDate.compareTo(a.transactionDate)); // Newest first

      calculateBalance();
    } catch (e) {
      print('Error fetching transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateBalance() {
    balance = 0;
    for (var transaction in transactions) {
      if (transaction.isDebit) {
        balance -= transaction.amount; // Customer paid, reduces what they owe
      } else {
        balance +=
            transaction.amount; // Customer charged, increases what they owe
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        title: Text("${widget.customer.name} - Ledger"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Customer info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Customer name and contact
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              widget.customer.name.isNotEmpty
                                  ? widget.customer.name[0].toUpperCase()
                                  : "C",
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.customer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.customer.phone.isNotEmpty)
                                  Text(
                                    widget.customer.phone,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Balance information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Current Balance:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${balance.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: balance > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            balance > 0
                                ? "Customer owes you"
                                : balance < 0
                                    ? "You owe customer"
                                    : "No pending balance",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transaction list header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Optional filter button
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // Implement filtering
                        },
                      ),
                    ],
                  ),
                ),

                // Transactions list
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
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
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionCard(transaction: transaction);
                          },
                        ),
                ),
              ],
            ),

      // FAB to add a payment
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add payment screen
          // You'll need to implement this
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Payment"),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final CustomerTransactionModel transaction;
  final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

  TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  transaction.isDebit
                      ? "-₹${transaction.amount.toStringAsFixed(2)}"
                      : "+₹${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.isDebit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      transaction.isDebit ? Icons.payment : Icons.shopping_cart,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.reference,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormat.format(transaction.transactionDate.toDate()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (transaction.paymentMethod.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Payment: ${transaction.paymentMethod}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
