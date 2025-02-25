import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/model/customer_model.dart';
import 'package:stockflow/model/product_model.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/viewmodel/customer_provider.dart';
import 'package:stockflow/viewmodel/product_provider.dart';
import 'package:stockflow/viewmodel/sales_provider.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class AddSalesDetails extends StatefulWidget {
  const AddSalesDetails({super.key});

  @override
  State<AddSalesDetails> createState() => _AddSalesDetailsState();
}

class _AddSalesDetailsState extends State<AddSalesDetails> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  CustomerModel? _selectedCustomer;
  ProductModel? _selectedProduct;
  double _totalAmount = 0.0;
  final _auth = FirebaseAuth.instance;

  // New fields
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Bank Transfer',
    'UPI',
    'Online Payment'
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize providers with data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Get the current user directly from FirebaseAuth
      final user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        customerProvider.fetchCustomers(userId);
        productProvider.initialize(userId);
      }
    });

    // Listen to quantity changes
    _quantityController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_updateTotal);
    _quantityController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
      try {
        int quantity = int.parse(_quantityController.text);
        setState(() {
          _totalAmount = _selectedProduct!.price * quantity;
        });
      } catch (e) {
        // Handle invalid input
        setState(() {
          _totalAmount = 0.0;
        });
      }
    } else {
      setState(() {
        _totalAmount = 0.0;
      });
    }
  }

  // Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSalesReport() async {
    if (_formKey.currentState!.validate() &&
        _selectedCustomer != null &&
        _selectedProduct != null) {
      setState(() {
        _isSubmitting = true;
      });

      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final quantity = int.parse(_quantityController.text);

      // Get the current user directly from FirebaseAuth
      final user = _auth.currentUser;
      if (user != null) {
        final success = await salesProvider.addSale(
          userId: user.uid,
          customerId: _selectedCustomer!.id,
          customerName: _selectedCustomer!.name,
          productId: _selectedProduct!.id,
          productName: _selectedProduct!.name,
          quantity: quantity,
          price: _selectedProduct!.price,
          totalAmount: _totalAmount,
          saleDate: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          productProvider: productProvider,
        );

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          _updateProductStock(quantity);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Sales report added successfully',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: AppColors.successColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Reset form
          setState(() {
            _selectedCustomer = null;
            _selectedProduct = null;
            _quantityController.text = '1';
            _totalAmount = 0.0;
            _selectedDate = DateTime.now();
            _selectedPaymentMethod = 'Cash';
          });

          _formKey.currentState!.reset();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    salesProvider.errorMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isSubmitting = false;
        });

        // User not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'User not authenticated. Please log in again.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _updateProductStock(int quantity) async {
    // Update product quantity after sale
    if (_selectedProduct != null) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final updatedQuantity = _selectedProduct!.quantity - quantity;

      if (updatedQuantity >= 0) {
        await productProvider.updateProduct(
          id: _selectedProduct!.id,
          name: _selectedProduct!.name,
          description: _selectedProduct!.description,
          quantity: updatedQuantity,
          price: _selectedProduct!.price,
        );
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required Widget field,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        field,
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: "Add Sales Report"),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Header
                    const Center(
                      child: Icon(
                        Icons.shopping_cart,
                        size: 48,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        "New Sale Entry",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        "Complete the form below to record a new sale",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Divider(height: 40),

                    // Date Selection
                    _buildFormField(
                      label: 'Sale Date',
                      field: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.calendar_today,
                                  color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Customer Selection
                    _buildFormField(
                      label: 'Select Customer',
                      field: customerProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ))
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonFormField<CustomerModel>(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  prefixIcon: Icon(Icons.person,
                                      color: Colors.grey.shade600),
                                ),
                                hint: const Text('Select a customer'),
                                value: _selectedCustomer,
                                items:
                                    customerProvider.customers.map((customer) {
                                  return DropdownMenuItem<CustomerModel>(
                                    value: customer,
                                    child: Text(customer.name),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a customer';
                                  }
                                  return null;
                                },
                                onChanged: (CustomerModel? newValue) {
                                  setState(() {
                                    _selectedCustomer = newValue;
                                  });
                                },
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppColors.primaryColor),
                              ),
                            ),
                    ),

                    // Product Selection
                    _buildFormField(
                      label: 'Select Product',
                      field: productProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ))
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonFormField<ProductModel>(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  prefixIcon: Icon(Icons.inventory,
                                      color: Colors.grey.shade600),
                                ),
                                hint: const Text('Select a product'),
                                value: _selectedProduct,
                                items: productProvider.products.map((product) {
                                  return DropdownMenuItem<ProductModel>(
                                    value: product,
                                    child: Row(
                                      children: [
                                        Text(product.name),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: product.quantity > 0
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Stock: ${product.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: product.quantity > 0
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a product';
                                  }
                                  if (value.quantity <= 0) {
                                    return 'This product is out of stock';
                                  }
                                  return null;
                                },
                                onChanged: (ProductModel? newValue) {
                                  setState(() {
                                    _selectedProduct = newValue;
                                    _updateTotal();
                                  });
                                },
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: AppColors.primaryColor),
                              ),
                            ),
                    ),

                    // Quantity with plus/minus controls
                    _buildFormField(
                      label: 'Quantity',
                      field: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primaryColor,
                              onPressed: () {
                                int currentValue =
                                    int.tryParse(_quantityController.text) ?? 1;
                                if (currentValue > 1) {
                                  _quantityController.text =
                                      (currentValue - 1).toString();
                                }
                              },
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  hintText: 'Enter quantity',
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter quantity';
                                  }
                                  try {
                                    final quantity = int.parse(value);
                                    if (quantity <= 0) {
                                      return 'Quantity must be greater than 0';
                                    }
                                    if (_selectedProduct != null &&
                                        quantity > _selectedProduct!.quantity) {
                                      return 'Not enough stock available';
                                    }
                                  } catch (e) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primaryColor,
                              onPressed: () {
                                int currentValue =
                                    int.tryParse(_quantityController.text) ?? 0;
                                int maxValue =
                                    _selectedProduct?.quantity ?? 999;
                                if (currentValue < maxValue) {
                                  _quantityController.text =
                                      (currentValue + 1).toString();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      helperText: _selectedProduct != null
                          ? 'Available stock: ${_selectedProduct!.quantity}'
                          : null,
                    ),

                    // Payment Method with icons
                    _buildFormField(
                      label: 'Payment Method',
                      field: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            prefixIcon: Icon(Icons.payment,
                                color: Colors.grey.shade600),
                          ),
                          value: _selectedPaymentMethod,
                          items: _paymentMethods.map((method) {
                            IconData iconData;
                            switch (method) {
                              case 'Cash':
                                iconData = Icons.money;
                                break;
                              case 'Credit Card':
                                iconData = Icons.credit_card;
                                break;
                              case 'Bank Transfer':
                                iconData = Icons.account_balance;
                                break;
                              case 'UPI':
                                iconData = Icons.phone_android;
                                break;
                              case 'Online Payment':
                                iconData = Icons.language;
                                break;
                              default:
                                iconData = Icons.payment;
                            }

                            return DropdownMenuItem<String>(
                              value: method,
                              child: Row(
                                children: [
                                  Icon(iconData,
                                      size: 20, color: AppColors.primaryColor),
                                  const SizedBox(width: 12),
                                  Text(method),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPaymentMethod = newValue;
                              });
                            }
                          },
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: AppColors.primaryColor),
                        ),
                      ),
                    ),

                    // Price and Total
                    if (_selectedProduct != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Unit Price:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '\$${_selectedProduct!.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${_totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const SizedBox(height: 16),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: _isSubmitting
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _saveSalesReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.textColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.save),
                                  SizedBox(width: 12),
                                  Text(
                                    "Save Sales Report",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
