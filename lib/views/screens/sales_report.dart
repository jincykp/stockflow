import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stockflow/model/sales_model.dart';
import 'package:stockflow/viewmodel/sales_provider.dart';
import 'package:stockflow/viewmodel/user_provider.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/widgets/loading_widget.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPaymentMethod = 'All';
  final List<String> _paymentMethods = [
    'All',
    'Cash',
    'Credit Card',
    'Bank Transfer',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch latest sales data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.uid ?? '';

      debugPrint("SalesReportScreen - User ID for fetch: $userId");
      debugPrint(
          "SalesReportScreen - User authenticated: ${userProvider.user != null}");

      salesProvider.fetchSales(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sales Report"),
      body: Consumer<SalesProvider>(
        builder: (context, salesProvider, child) {
          if (salesProvider.isLoading) {
            return const LoadingWidget();
          }

          if (salesProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                salesProvider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final filteredSales = _getFilteredSales(salesProvider);

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildFilterSection(),
                      const SizedBox(height: 8),
                      _buildSummaryCards(filteredSales),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Sales List'),
                        Tab(text: 'Summary'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesList(filteredSales),
                _buildSalesSummary(filteredSales),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedPaymentMethod,
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<SalesModel> sales) {
    final totalSales = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final totalItems = sales.fold(0, (sum, sale) => sum + sale.quantity);
    final uniqueCustomers = sales.map((sale) => sale.customerId).toSet().length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildSummaryCard('Total Sales',
              'Rs. ${totalSales.toStringAsFixed(2)}', Colors.blue),
          const SizedBox(width: 12),
          _buildSummaryCard('Items Sold', totalItems.toString(), Colors.green),
          const SizedBox(width: 12),
          _buildSummaryCard(
              'Customers', uniqueCustomers.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList(List<SalesModel> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Text('No sales data found for the selected filters'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              sale.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${sale.customerName}'),
                Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(sale.saleDate.toDate())}'),
                Text('Payment: ${sale.paymentMethod}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${sale.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('Qty: ${sale.quantity}'),
              ],
            ),
            onTap: () {
              // Navigate to sale details page if needed
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SaleDetailScreen(sale: sale)));
            },
          ),
        );
      },
    );
  }

  Widget _buildSalesSummary(List<SalesModel> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Text('No sales data found for the selected filters'),
      );
    }

    // Group sales by payment method
    final paymentMethodSummary = <String, double>{};
    for (final sale in sales) {
      final method = sale.paymentMethod;
      paymentMethodSummary[method] =
          (paymentMethodSummary[method] ?? 0) + sale.totalAmount;
    }

    // Group sales by product
    final productSummary = <String, Map<String, dynamic>>{};
    for (final sale in sales) {
      if (!productSummary.containsKey(sale.productId)) {
        productSummary[sale.productId] = {
          'name': sale.productName,
          'quantity': 0,
          'amount': 0.0,
        };
      }

      productSummary[sale.productId]!['quantity'] =
          (productSummary[sale.productId]!['quantity'] as int) + sale.quantity;
      productSummary[sale.productId]!['amount'] =
          (productSummary[sale.productId]!['amount'] as double) +
              sale.totalAmount;
    }

    // Group sales by customer
    final customerSummary = <String, Map<String, dynamic>>{};
    for (final sale in sales) {
      if (!customerSummary.containsKey(sale.customerId)) {
        customerSummary[sale.customerId] = {
          'name': sale.customerName,
          'purchases': 0,
          'amount': 0.0,
        };
      }

      customerSummary[sale.customerId]!['purchases'] =
          (customerSummary[sale.customerId]!['purchases'] as int) + 1;
      customerSummary[sale.customerId]!['amount'] =
          (customerSummary[sale.customerId]!['amount'] as double) +
              sale.totalAmount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method Summary
          const Text(
            'Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethodSummary.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final method = paymentMethodSummary.keys.elementAt(index);
                final amount = paymentMethodSummary[method]!;
                return ListTile(
                  title: Text(method),
                  trailing: Text(
                    'Rs. ${amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Top Products
          const Text(
            'Top Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productSummary.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final productId = productSummary.keys.elementAt(index);
                final product = productSummary[productId]!;
                return ListTile(
                  title: Text(product['name'] as String),
                  subtitle: Text('Quantity: ${product['quantity']}'),
                  trailing: Text(
                    'Rs. ${(product['amount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Top Customers
          const Text(
            'Top Customers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customerSummary.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final customerId = customerSummary.keys.elementAt(index);
                final customer = customerSummary[customerId]!;
                return ListTile(
                  title: Text(customer['name'] as String),
                  subtitle: Text('Purchases: ${customer['purchases']}'),
                  trailing: Text(
                    'Rs. ${(customer['amount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<SalesModel> _getFilteredSales(SalesProvider provider) {
    // First filter by date range
    List<SalesModel> filteredSales =
        provider.getSalesByDateRange(_startDate, _endDate);

    // Then filter by payment method if not "All"
    if (_selectedPaymentMethod != 'All') {
      filteredSales = filteredSales
          .where((sale) => sale.paymentMethod == _selectedPaymentMethod)
          .toList();
    }

    // Sort by date (most recent first)
    filteredSales.sort((a, b) => b.saleDate.compareTo(a.saleDate));

    return filteredSales;
  }
}

// This delegate class is used by the SliverPersistentHeader to manage the TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
