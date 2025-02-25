import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/customer_provider.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    // If the selected customer is not set or doesn't match the ID, fetch it
    if (customerProvider.selectedCustomer?.id != widget.customerId) {
      // This would require adding a getCustomerById method to your provider
      await customerProvider.getCustomerById(widget.customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Customer Details'),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
          }

          if (customerProvider.selectedCustomer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Customer not found',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final customer = customerProvider.selectedCustomer!;
          return _buildCustomerDetails(context, customer, customerProvider);
        },
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context, CustomerModel customer,
      CustomerProvider customerProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // Contact information section
          _buildSectionHeader('Contact Information'),
          _buildInfoTile(Icons.email_outlined, 'Email', customer.email),
          _buildInfoTile(Icons.phone_outlined, 'Phone', customer.phone),
          _buildInfoTile(
              Icons.location_on_outlined, 'Address', customer.address),

          SizedBox(height: 24),

          // Notes section
          _buildSectionHeader('Notes'),
          Card(
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                customer.notes.isNotEmpty
                    ? customer.notes
                    : 'No additional notes',
                style: TextStyle(
                  color: customer.notes.isNotEmpty
                      ? AppColors.standardBlackColor
                      : AppColors.lightShadeColor,
                ),
              ),
            ),
          ),

          SizedBox(height: 32),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.edit_outlined),
                  label: Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _confirmDeleteDialog(context, customerProvider),
                  icon:
                      Icon(Icons.delete_outline, color: AppColors.warningColor),
                  label: Text('Delete',
                      style: TextStyle(color: AppColors.warningColor)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.specialColor, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: TextStyle(
                    fontSize: 16,
                    color: value.isNotEmpty
                        ? AppColors.standardBlackColor
                        : AppColors.lightShadeColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(BuildContext context, CustomerProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete this customer? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog

                final success =
                    await provider.deleteCustomer(widget.customerId);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); // Go back to home
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Failed to delete customer: ${provider.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
