import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/customer_ledger_screen.dart';

class CustomerListScreen extends StatefulWidget {
  final bool selectionMode;
  final String title;

  const CustomerListScreen({
    Key? key,
    this.selectionMode = false,
    this.title = "Customers",
  }) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Customer list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                // Filter customers based on search query
                List<CustomerModel> customers = snapshot.data!.docs
                    .map((doc) => CustomerModel.fromMap({
                          ...doc.data() as Map<String, dynamic>,
                          'id': doc.id,
                        }))
                    .where((customer) =>
                        customer.name.toLowerCase().contains(_searchQuery) ||
                        customer.phone.toLowerCase().contains(_searchQuery) ||
                        customer.email.toLowerCase().contains(_searchQuery))
                    .toList();

                if (customers.isEmpty) {
                  return const Center(
                      child: Text('No matching customers found'));
                }

                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerListItem(
                      customer: customer,
                      onTap: () {
                        if (widget.selectionMode) {
                          // Navigate to ledger with selected customer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerLedgerScreen(
                                customer: customer,
                              ),
                            ),
                          );
                        } else {
                          // Handle normal customer selection (e.g., view details)
                          // Implement as needed
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CustomerListItem extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const CustomerListItem({
    Key? key,
    required this.customer,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "C",
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(customer.name),
        subtitle: Text(customer.phone),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
