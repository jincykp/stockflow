import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/customer_provider.dart';
import 'package:stockflow/views/screens/add_customer.dart';
import 'package:stockflow/views/screens/customer_detail_view.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  @override
  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Load customers using provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<CustomerProvider>(context, listen: false)
            .fetchCustomers(currentUser.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'StockFlow'),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          }

          if (customerProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading customers',
                    style:
                        TextStyle(fontSize: 18, color: AppColors.primaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(customerProvider.errorMessage),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCustomers,
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (customerProvider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline,
                      size: 64, color: AppColors.lightShadeColor),
                  SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCustomer()),
                    ),
                    icon: Icon(Icons.person_add_outlined),
                    label: Text('Add Your First Customer'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: customerProvider.customers.length,
            itemBuilder: (context, index) {
              final customer = customerProvider.customers[index];
              return _buildCustomerCard(customer);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCustomer()),
        ),
        child: Icon(Icons.person_add_outlined),
        tooltip: 'Add Customer',
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (customer.email.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(customer.email),
                ],
              ),
            if (customer.phone.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(customer.phone),
                ],
              ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Set selected customer and navigate to detail page
          Provider.of<CustomerProvider>(context, listen: false)
              .selectCustomer(customer);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailPage(customerId: customer.id),
            ),
          );
        },
      ),
    );
  }
}
